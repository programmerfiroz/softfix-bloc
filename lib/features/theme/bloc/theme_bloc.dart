import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/storage/shared_prefs.dart';
import '../../../core/utils/logger.dart';
import 'theme_event.dart';
import 'theme_state.dart';
import '../services/theme_service.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _brightnessModeKey = 'brightness_mode';
  static const String _themeIdKey = 'theme_id';

  ThemeBloc()
      : super(const ThemeState(
    brightnessMode: ThemeBrightnessMode.system,
    selectedThemeId: 1,
    availableThemes: [],
    isLoading: true,
  )) {
    on<LoadThemesEvent>(_onLoadThemes);
    on<LoadSavedThemeEvent>(_onLoadSavedTheme);
    on<ChangeBrightnessModeEvent>(_onChangeBrightnessMode);
    on<ChangeThemeColorEvent>(_onChangeThemeColor);
    on<ChangeCompleteThemeEvent>(_onChangeCompleteTheme);
    on<ReloadThemesEvent>(_onReloadThemes);
  }

  Future<void> _onLoadThemes(
      LoadThemesEvent event,
      Emitter<ThemeState> emit,
      ) async {
    emit(state.copyWith(isLoading: true));

    try {
      Logger.i('Loading themes...');

      // Load themes from API or local JSON
      final themes = await ThemeService.loadThemes();

      if (themes.isEmpty) {
        Logger.e('No themes loaded, using default');
        final defaultTheme = ThemeService.getDefaultTheme();
        emit(state.copyWith(
          availableThemes: [defaultTheme],
          selectedThemeId: defaultTheme.id,
          isLoading: false,
        ));
        return;
      }

      final defaultTheme = ThemeService.getDefaultTheme();
      Logger.i('Loaded ${themes.length} themes, default theme id: ${defaultTheme.id}');

      emit(state.copyWith(
        availableThemes: themes,
        selectedThemeId: defaultTheme.id,
        isLoading: false,
      ));

      // After loading themes, load saved preferences
      add(LoadSavedThemeEvent());

    } catch (e) {
      Logger.e('Error loading themes: $e');

      // Use default theme on error
      final defaultTheme = ThemeService.getDefaultTheme();
      emit(state.copyWith(
        availableThemes: [defaultTheme],
        selectedThemeId: defaultTheme.id,
        isLoading: false,
      ));
    }
  }

  Future<void> _onLoadSavedTheme(
      LoadSavedThemeEvent event,
      Emitter<ThemeState> emit,
      ) async {
    try {
      final savedBrightnessMode = SharedPrefs.getString(_brightnessModeKey);
      final savedThemeId = SharedPrefs.getInt(_themeIdKey);

      Logger.i('Loading saved theme preferences: brightness=$savedBrightnessMode, themeId=$savedThemeId');

      // Validate saved theme ID exists in available themes
      int themeId = savedThemeId ?? state.selectedThemeId;
      if (savedThemeId != null) {
        final themeExists = state.availableThemes.any((t) => t.id == savedThemeId);
        if (!themeExists) {
          Logger.w('Saved theme id $savedThemeId not found, using default');
          themeId = state.selectedThemeId;
        }
      }

      emit(state.copyWith(
        brightnessMode: _getBrightnessModeFromString(savedBrightnessMode),
        selectedThemeId: themeId,
      ));

    } catch (e) {
      Logger.e('Error loading saved theme: $e');
    }
  }

  Future<void> _onChangeBrightnessMode(
      ChangeBrightnessModeEvent event,
      Emitter<ThemeState> emit,
      ) async {
    try {
      await SharedPrefs.setString(_brightnessModeKey, event.mode.name);
      Logger.i('Brightness mode changed to: ${event.mode.name}');
      emit(state.copyWith(brightnessMode: event.mode));
    } catch (e) {
      Logger.e('Error changing brightness mode: $e');
    }
  }

  Future<void> _onChangeThemeColor(
      ChangeThemeColorEvent event,
      Emitter<ThemeState> emit,
      ) async {
    try {
      // Validate theme exists
      final themeExists = state.availableThemes.any((t) => t.id == event.themeId);
      if (!themeExists) {
        Logger.w('Theme id ${event.themeId} not found');
        return;
      }

      await SharedPrefs.setInt(_themeIdKey, event.themeId);
      Logger.i('Theme color changed to id: ${event.themeId}');
      emit(state.copyWith(selectedThemeId: event.themeId));
    } catch (e) {
      Logger.e('Error changing theme color: $e');
    }
  }

  Future<void> _onChangeCompleteTheme(
      ChangeCompleteThemeEvent event,
      Emitter<ThemeState> emit,
      ) async {
    try {
      // Validate theme exists
      final themeExists = state.availableThemes.any((t) => t.id == event.themeId);
      if (!themeExists) {
        Logger.w('Theme id ${event.themeId} not found');
        return;
      }

      await SharedPrefs.setString(_brightnessModeKey, event.mode.name);
      await SharedPrefs.setInt(_themeIdKey, event.themeId);

      Logger.i('Complete theme changed: brightness=${event.mode.name}, themeId=${event.themeId}');

      emit(state.copyWith(
        brightnessMode: event.mode,
        selectedThemeId: event.themeId,
      ));
    } catch (e) {
      Logger.e('Error changing complete theme: $e');
    }
  }

  Future<void> _onReloadThemes(
      ReloadThemesEvent event,
      Emitter<ThemeState> emit,
      ) async {
    emit(state.copyWith(isLoading: true));

    try {
      Logger.i('Reloading themes...');

      // Clear cache and reload
      final themes = await ThemeService.reloadThemes();

      if (themes.isEmpty) {
        Logger.e('No themes loaded after reload, using default');
        final defaultTheme = ThemeService.getDefaultTheme();
        emit(state.copyWith(
          availableThemes: [defaultTheme],
          selectedThemeId: defaultTheme.id,
          isLoading: false,
        ));
        return;
      }

      // Keep current selection if possible
      int selectedId = state.selectedThemeId;
      final themeExists = themes.any((t) => t.id == selectedId);
      if (!themeExists) {
        selectedId = ThemeService.getDefaultTheme().id;
        Logger.w('Current theme not found after reload, using default');
      }

      Logger.i('Themes reloaded successfully');

      emit(state.copyWith(
        availableThemes: themes,
        selectedThemeId: selectedId,
        isLoading: false,
      ));

    } catch (e) {
      Logger.e('Error reloading themes: $e');
      emit(state.copyWith(isLoading: false));
    }
  }

  ThemeBrightnessMode _getBrightnessModeFromString(String? value) {
    switch (value) {
      case 'light':
        return ThemeBrightnessMode.light;
      case 'dark':
        return ThemeBrightnessMode.dark;
      case 'system':
      default:
        return ThemeBrightnessMode.system;
    }
  }
}