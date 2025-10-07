import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_event.dart';
import 'theme_state.dart';
import '../../services/storage/shared_prefs.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themeKey = 'app_theme';

  ThemeBloc()
      : super(const ThemeState(
    theme: AppThemeEnum.system,
  )) {
    on<LoadThemeEvent>(_onLoadTheme);
    on<ChangeThemeEvent>(_onChangeTheme);
  }

  Future<void> _onLoadTheme(
      LoadThemeEvent event,
      Emitter<ThemeState> emit,
      ) async {
    final savedTheme = SharedPrefs.getString(_themeKey);
    emit(state.copyWith(
      theme: _getThemeFromString(savedTheme),
    ));
  }

  Future<void> _onChangeTheme(
      ChangeThemeEvent event,
      Emitter<ThemeState> emit,
      ) async {
    await SharedPrefs.setString(_themeKey, event.theme.name);
    emit(state.copyWith(theme: event.theme));
  }

  AppThemeEnum _getThemeFromString(String? value) {
    switch (value) {
      case 'light':
        return AppThemeEnum.light;
      case 'dark':
        return AppThemeEnum.dark;
      case 'blue':
        return AppThemeEnum.blue;
      case 'yellow':
        return AppThemeEnum.yellow;
      case 'system':
      default:
        return AppThemeEnum.system;
    }
  }
}