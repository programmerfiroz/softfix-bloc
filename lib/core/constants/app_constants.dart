
import '../services/config/env_config.dart';

class AppConstants {
  static String appName = EnvConfig.appName;
  static String baseUrl = EnvConfig.baseUrl;
  static const String fontFamily = 'Poppins';
  static const String defaultTag = 'Softfix';


  static const String favoritesBoxName = 'favorites';
  static const String favoriteIdsKey = 'favorite_ids';

  static const String errorMessage = 'Something went wrong. Please try again.';
  static const String noDataMessage = 'No users found.';
  static const String noFavoritesMessage = 'No favorite users yet.';

  // ====== Shared Preferences keys start ======
  static const String languagePref = 'selected_language';
  static const bool languageStatusPref = true;
  static const String themeModePref = 'theme_mode';
  static const bool themeModeStatusPref = true;
  static const String tokenPref = 'token';
  static const String userDataPref = 'user_data';
  static const String isLoggedInPref = 'is_logged_in';
// ====== Shared Preferences keys end ======

}
