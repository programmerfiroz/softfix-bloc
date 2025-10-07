import '../language_model.dart';

abstract class LanguageEvent {}

class LoadLanguagesEvent extends LanguageEvent {}

class SelectLanguageEvent extends LanguageEvent {
  final LanguageModel language;

  SelectLanguageEvent(this.language);
}
