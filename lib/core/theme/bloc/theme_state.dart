import 'package:equatable/equatable.dart';
import 'theme_event.dart';

class ThemeState extends Equatable {
  final AppThemeEnum theme;

  const ThemeState({
    required this.theme,
  });

  @override
  List<Object> get props => [theme];

  ThemeState copyWith({
    AppThemeEnum? theme,
  }) {
    return ThemeState(
      theme: theme ?? this.theme,
    );
  }
}