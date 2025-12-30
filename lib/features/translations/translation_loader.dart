import 'services/language_service.dart';

class TranslationLoader {
  static Future<Map<String, String>> load(String locale) async {
    final languageCode = locale.split('_')[0];
    final translations = LanguageService.getTranslations(languageCode);
    return translations ?? {};
  }

  static String? getTranslation(String languageCode, String key) {
    return LanguageService.getTranslation(languageCode, key);
  }
}