import 'package:flutter/material.dart';
import 'AppTheme/light_theme.dart';
import 'AppTheme/dark_theme.dart';
import 'AppTheme/blue_theme.dart';
import 'AppTheme/yellow_theme.dart';
import 'bloc/theme_event.dart';

class AppTheme {
  // Get light theme based on selection
  static ThemeData getLightTheme(AppThemeEnum theme) {
    switch (theme) {
      case AppThemeEnum.blue:
        return blueTheme;
      case AppThemeEnum.yellow:
        return yellowTheme;
      case AppThemeEnum.system:
      case AppThemeEnum.light:
      case AppThemeEnum.dark:
      default:
        return lightTheme;
    }
  }

  // Dark theme - same for all
  static ThemeData getDarkTheme(AppThemeEnum theme) {
    return darkTheme;
  }

  // Get theme mode
  static ThemeMode getThemeMode(AppThemeEnum theme) {
    switch (theme) {
      case AppThemeEnum.light:
      case AppThemeEnum.blue:
      case AppThemeEnum.yellow:
        return ThemeMode.light;
      case AppThemeEnum.dark:
        return ThemeMode.dark;
      case AppThemeEnum.system:
      default:
        return ThemeMode.system;
    }
  }
}