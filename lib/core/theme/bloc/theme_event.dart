import 'package:equatable/equatable.dart';

enum AppThemeEnum { system, light, dark, blue, yellow }

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class LoadThemeEvent extends ThemeEvent {}

class ChangeThemeEvent extends ThemeEvent {
  final AppThemeEnum theme;

  const ChangeThemeEvent(this.theme);

  @override
  List<Object> get props => [theme];
}