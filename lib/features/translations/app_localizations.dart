import 'package:flutter/material.dart';
import 'translation_loader.dart';
import 'services/language_service.dart';

class AppLocalizations {
  final Locale locale;
  Map<String, String> _localizedStrings = {};

  AppLocalizations(this.locale);

  Future<void> load() async {
    _localizedStrings = await TranslationLoader.load(
        '${locale.languageCode}_${locale.countryCode}');
  }

  String translate(String key) => _localizedStrings[key] ?? key;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }
}

class AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Dynamically check if language is supported based on loaded languages
    final availableLanguages = LanguageService.getAvailableLanguageCodes();
    return availableLanguages.contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}