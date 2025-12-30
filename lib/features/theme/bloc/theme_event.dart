import 'package:equatable/equatable.dart';
import 'theme_state.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

// Load themes from JSON/API
class LoadThemesEvent extends ThemeEvent {}

// Load saved theme preference
class LoadSavedThemeEvent extends ThemeEvent {}

// Reload themes (clears cache and loads fresh)
class ReloadThemesEvent extends ThemeEvent {}

// Change brightness mode (system/light/dark)
class ChangeBrightnessModeEvent extends ThemeEvent {
  final ThemeBrightnessMode mode;

  const ChangeBrightnessModeEvent(this.mode);

  @override
  List<Object> get props => [mode];
}

// Change theme color (by ID)
class ChangeThemeColorEvent extends ThemeEvent {
  final int themeId;

  const ChangeThemeColorEvent(this.themeId);

  @override
  List<Object> get props => [themeId];
}

// Change both brightness and theme color
class ChangeCompleteThemeEvent extends ThemeEvent {
  final ThemeBrightnessMode mode;
  final int themeId;

  const ChangeCompleteThemeEvent({
    required this.mode,
    required this.themeId,
  });

  @override
  List<Object> get props => [mode, themeId];
}