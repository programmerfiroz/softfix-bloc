import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/constants/api_constents.dart';
import '../../../core/utils/logger.dart';
import '../models/language_model.dart';

class LanguageService {
    static final ApiClient _apiClient = ApiClient();
    static List<LanguageModel>? _cachedLanguages;
    static Map<String, Map<String, String>>? _cachedTranslations;

    /// Load languages from API with fallback to local JSON
    static Future<List<LanguageModel>> loadLanguagesFromApi() async {
        try {
            Logger.i('Loading languages from API: ${ApiConstants.languages}');

            final response = await _apiClient.get(
                ApiConstants.languages,
                handleError: false,
                showToaster: false,
                enableRetry: true,
            );

            if (response.statusCode == 200 || response.statusCode == 201) {
                final data = response.data;

                // Check if data is valid
                if (data != null && data['res'] == 'success') {
                    final languageResponse = LanguageResponse.fromJson(data);

                    if (languageResponse.data.languages.isNotEmpty) {
                        _cachedLanguages = languageResponse.data.languages;
                        _cachedTranslations = languageResponse.data.translations;

                        Logger.i('Successfully loaded ${_cachedLanguages!.length} languages from API');
                        return _cachedLanguages!;
                    }
                }
            }

            Logger.w('API response invalid, falling back to local JSON');
            return await _loadLanguagesFromJson();

        } catch (e) {
            Logger.e('Error loading languages from API: $e');
            Logger.i('Falling back to local JSON');
            return await _loadLanguagesFromJson();
        }
    }

    /// Load languages from local JSON file (fallback)
    static Future<List<LanguageModel>> _loadLanguagesFromJson() async {
        if (_cachedLanguages != null && _cachedLanguages!.isNotEmpty) {
            Logger.i('Returning cached languages from JSON');
            return _cachedLanguages!;
        }

        try {
            Logger.i('Loading languages from local JSON file');
            final String response = await rootBundle.loadString('assets/json/languages.json');
            final data = json.decode(response);
            final languageResponse = LanguageResponse.fromJson(data);

            _cachedLanguages = languageResponse.data.languages;
            _cachedTranslations = languageResponse.data.translations;

            Logger.i('Successfully loaded ${_cachedLanguages!.length} languages from JSON');
            return _cachedLanguages!;

        } catch (e) {
            Logger.e('Error loading languages from JSON: $e');
            Logger.i('Using default languages as last resort');
            return _getDefaultLanguages();
        }
    }

    /// Load languages (tries API first if enabled, falls back to JSON)
    static Future<List<LanguageModel>> loadLanguages() async {
        try {
            if (AppConstants.languageStatusPref) {
                Logger.i('Language API is enabled, trying API first');
                return await loadLanguagesFromApi();
            } else {
                Logger.i('Language API is disabled, using local JSON');
                return await _loadLanguagesFromJson();
            }
        } catch (e) {
            Logger.e('Error in loadLanguages: $e');
            return _getDefaultLanguages();
        }
    }

    /// Get language by ID
    static LanguageModel? getLanguageById(int id) {
        if (_cachedLanguages == null || _cachedLanguages!.isEmpty) {
            Logger.w('No cached languages available');
            return null;
        }

        try {
            return _cachedLanguages!.firstWhere((lang) => lang.id == id);
        } catch (e) {
            Logger.w('Language with id $id not found');
            return null;
        }
    }

    /// Get language by code
    static LanguageModel? getLanguageByCode(String languageCode) {
        if (_cachedLanguages == null || _cachedLanguages!.isEmpty) {
            Logger.w('No cached languages available');
            return null;
        }

        try {
            return _cachedLanguages!.firstWhere(
                    (lang) => lang.languageCode == languageCode,
            );
        } catch (e) {
            Logger.w('Language with code $languageCode not found');
            return null;
        }
    }

    /// Get default language
    static LanguageModel getDefaultLanguage() {
        if (_cachedLanguages != null && _cachedLanguages!.isNotEmpty) {
            try {
                return _cachedLanguages!.firstWhere((lang) => lang.isDefault);
            } catch (e) {
                Logger.w('No default language found, returning first language');
                return _cachedLanguages!.first;
            }
        }

        Logger.w('No cached languages, returning hardcoded default');
        return _getDefaultLanguages().first;
    }

    /// Get translation by key
    static String? getTranslation(String languageCode, String key) {
        if (_cachedTranslations == null) {
            Logger.w('No translations cached');
            return null;
        }

        final translation = _cachedTranslations![languageCode]?[key];
        if (translation == null) {
            Logger.d('Translation not found for key: $key in language: $languageCode');
        }
        return translation;
    }

    /// Get all translations for a language
    static Map<String, String>? getTranslations(String languageCode) {
        if (_cachedTranslations == null) {
            Logger.w('No translations cached');
            return null;
        }

        final translations = _cachedTranslations![languageCode];
        if (translations == null) {
            Logger.w('No translations found for language: $languageCode');
        }
        return translations;
    }

    /// Get all available language codes
    static List<String> getAvailableLanguageCodes() {
        if (_cachedLanguages == null || _cachedLanguages!.isEmpty) {
            return ['en'];
        }
        return _cachedLanguages!.map((lang) => lang.languageCode).toList();
    }

    /// Check if translations are loaded
    static bool isTranslationsLoaded() {
        return _cachedTranslations != null && _cachedTranslations!.isNotEmpty;
    }

    /// Fallback default languages
    static List<LanguageModel> _getDefaultLanguages() {
        Logger.i('Using hardcoded default language');
        return [
            LanguageModel(
                id: 1,
                imageUrl: 'https://flagcdn.com/w80/us.png',
                languageName: 'English',
                languageCode: 'en',
                countryCode: 'US',
                isDefault: true,
            )
        ];
    }

    /// Clear cache
    static void clearCache() {
        _cachedLanguages = null;
        _cachedTranslations = null;
        Logger.i('Language cache cleared');
    }

    /// Reload languages (clears cache and loads fresh)
    static Future<List<LanguageModel>> reloadLanguages() async {
        Logger.i('Reloading languages...');
        clearCache();
        return await loadLanguages();
    }
}