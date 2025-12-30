import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/constants/api_constents.dart';
import '../../../core/utils/logger.dart';
import '../models/theme_model.dart';

class ThemeService {
  static final ApiClient _apiClient = ApiClient();
  static List<ThemeModel>? _cachedThemes;

  /// Load themes from API with fallback to local JSON
  static Future<List<ThemeModel>> loadThemesFromApi() async {
    try {
      Logger.i('Loading themes from API: ${ApiConstants.themes}');

      final response = await _apiClient.get(
        ApiConstants.themes,
        handleError: false,
        showToaster: false,
        enableRetry: true,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        // Check if data is valid
        if (data != null && data['res'] == 'success') {
          final themeResponse = ThemeResponse.fromJson(data);

          if (themeResponse.data.isNotEmpty) {
            _cachedThemes = themeResponse.data;
            Logger.i('Successfully loaded ${_cachedThemes!.length} themes from API');
            return _cachedThemes!;
          }
        }
      }

      Logger.w('API response invalid, falling back to local JSON');
      return await _loadThemesFromJson();

    } catch (e) {
      Logger.e('Error loading themes from API: $e');
      Logger.i('Falling back to local JSON');
      return await _loadThemesFromJson();
    }
  }

  /// Load themes from local JSON file (fallback)
  static Future<List<ThemeModel>> _loadThemesFromJson() async {
    if (_cachedThemes != null && _cachedThemes!.isNotEmpty) {
      Logger.i('Returning cached themes from JSON');
      return _cachedThemes!;
    }

    try {
      Logger.i('Loading themes from local JSON file');
      final String response = await rootBundle.loadString('assets/json/themes.json');
      final data = json.decode(response);
      final themeResponse = ThemeResponse.fromJson(data);

      _cachedThemes = themeResponse.data;
      Logger.i('Successfully loaded ${_cachedThemes!.length} themes from JSON');
      return _cachedThemes!;

    } catch (e) {
      Logger.e('Error loading themes from JSON: $e');
      Logger.i('Using default themes as last resort');
      return _getDefaultThemes();
    }
  }

  /// Load themes (tries API first if enabled, falls back to JSON)
  static Future<List<ThemeModel>> loadThemes() async {
    try {
      if (AppConstants.themeModeStatusPref) {
        Logger.i('Theme API is enabled, trying API first');
        return await loadThemesFromApi();
      } else {
        Logger.i('Theme API is disabled, using local JSON');
        return await _loadThemesFromJson();
      }
    } catch (e) {
      Logger.e('Error in loadThemes: $e');
      return _getDefaultThemes();
    }
  }

  /// Get theme by ID
  static ThemeModel? getThemeById(int id) {
    if (_cachedThemes == null || _cachedThemes!.isEmpty) {
      Logger.w('No cached themes available');
      return null;
    }

    try {
      return _cachedThemes!.firstWhere((theme) => theme.id == id);
    } catch (e) {
      Logger.w('Theme with id $id not found');
      return null;
    }
  }

  /// Get default theme
  static ThemeModel getDefaultTheme() {
    if (_cachedThemes != null && _cachedThemes!.isNotEmpty) {
      try {
        return _cachedThemes!.firstWhere((theme) => theme.isDefault);
      } catch (e) {
        Logger.w('No default theme found, returning first theme');
        return _cachedThemes!.first;
      }
    }

    Logger.w('No cached themes, returning hardcoded default');
    return _getDefaultThemes().first;
  }

  /// Fallback default themes
  static List<ThemeModel> _getDefaultThemes() {
    Logger.i('Using hardcoded default theme');
    return [
      ThemeModel(
        id: 1,
        name: 'Default Dark Green',
        primaryColor: const Color(0xFF24292c),
        secondaryColor: const Color(0xFF62c64a),
        darkPrimaryColor: const Color(0xFF242a2a),
        darkSecondaryColor: const Color(0xFF62c64a),
        isDefault: true,
      ),
    ];
  }

  /// Clear cache (useful for refreshing themes)
  static void clearCache() {
    _cachedThemes = null;
    Logger.i('Theme cache cleared');
  }

  /// Reload themes (clears cache and loads fresh)
  static Future<List<ThemeModel>> reloadThemes() async {
    Logger.i('Reloading themes...');
    clearCache();
    return await loadThemes();
  }
}

