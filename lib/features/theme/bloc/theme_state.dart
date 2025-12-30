import 'package:equatable/equatable.dart';
import '../models/theme_model.dart';

enum ThemeBrightnessMode { system, light, dark }

class ThemeState extends Equatable {
  final ThemeBrightnessMode brightnessMode;
  final int selectedThemeId;
  final List<ThemeModel> availableThemes;
  final bool isLoading;

  const ThemeState({
    required this.brightnessMode,
    required this.selectedThemeId,
    required this.availableThemes,
    this.isLoading = false,
  });

  // Get current selected theme
  ThemeModel? get currentTheme {
    try {
      return availableThemes.firstWhere((theme) => theme.id == selectedThemeId);
    } catch (e) {
      return availableThemes.isNotEmpty ? availableThemes.first : null;
    }
  }

  @override
  List<Object> get props => [brightnessMode, selectedThemeId, availableThemes, isLoading];

  ThemeState copyWith({
    ThemeBrightnessMode? brightnessMode,
    int? selectedThemeId,
    List<ThemeModel>? availableThemes,
    bool? isLoading,
  }) {
    return ThemeState(
      brightnessMode: brightnessMode ?? this.brightnessMode,
      selectedThemeId: selectedThemeId ?? this.selectedThemeId,
      availableThemes: availableThemes ?? this.availableThemes,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}


