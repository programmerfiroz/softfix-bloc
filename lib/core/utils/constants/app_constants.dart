
import '../../services/config/env_config.dart';

class AppConstants {
  static String appName = EnvConfig.appName;
  static String baseUrl = EnvConfig.baseUrl;
  static const String fontFamily = 'Poppins';
  static const String defaultTag = 'Softfix';

  // API base URLs
  static  String imageUrl = '$baseUrl';

  // API endpoints
  // static  String usersApiUrl = '$baseUrl/uusers';
  static  String usersApiUrl = '$baseUrl/users';

  static const String favoritesBoxName = 'favorites';
  static const String favoriteIdsKey = 'favorite_ids';

  static const String errorMessage = 'Something went wrong. Please try again.';
  static const String noDataMessage = 'No users found.';
  static const String noFavoritesMessage = 'No favorite users yet.';

  // Shared Preferences keys
  static const String theme = 'theme';
  static const String language = 'language';
  static const String token = 'token';
  static const String userData = 'user_data';
  static const String isLoggedIn = 'is_logged_in';
}