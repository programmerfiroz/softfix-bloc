import '../models/language_model.dart';

abstract class LanguageEvent {}

/// Event to load languages from API or local JSON
class LoadLanguagesEvent extends LanguageEvent {
  final String? apiUrl;

  LoadLanguagesEvent({this.apiUrl});
}

/// Event to select a language
class SelectLanguageEvent extends LanguageEvent {
  final LanguageModel language;

  SelectLanguageEvent(this.language);
}

/// Event to reload languages (clears cache and loads fresh)
class ReloadLanguagesEvent extends LanguageEvent {
  final String? apiUrl;

  ReloadLanguagesEvent({this.apiUrl});
} 