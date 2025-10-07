import 'package:softfix_user/core/utils/constants/app_constants.dart';

import '../../../core/services/storage/hive_storage.dart';

class FavoriteStorageHelper {
  static const String _favoritesBoxName = AppConstants.favoritesBoxName;
  static const String _favoritesKey = AppConstants.favoriteIdsKey;

  /// Get all favorite user IDs
  static Future<List<int>> getAllFavoriteIds() async {
    try {
      final data = await HiveStorage.get(_favoritesBoxName, _favoritesKey);
      if (data is List) {
        return data.cast<int>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Add a user ID to favorites
  static Future<void> addFavorite(int userId) async {
    final currentFavorites = await getAllFavoriteIds();
    if (!currentFavorites.contains(userId)) {
      currentFavorites.add(userId);
      await HiveStorage.put(_favoritesBoxName, _favoritesKey, currentFavorites);
    }
  }

  /// Remove a user ID from favorites
  static Future<void> removeFavorite(int userId) async {
    final currentFavorites = await getAllFavoriteIds();
    currentFavorites.remove(userId);
    await HiveStorage.put(_favoritesBoxName, _favoritesKey, currentFavorites);
  }

  /// Check if a user ID is in favorites
  static Future<bool> isFavorite(int userId) async {
    final favorites = await getAllFavoriteIds();
    return favorites.contains(userId);
  }

  /// Clear all favorites
  static Future<void> clearAllFavorites() async {
    await HiveStorage.delete(_favoritesBoxName, _favoritesKey);
  }
}