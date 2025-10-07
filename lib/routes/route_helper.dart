import 'package:flutter/material.dart';
import 'package:softfix_user/presentation/screens/favorites_screen.dart';
import 'package:softfix_user/presentation/screens/user_detail_screen.dart';
import '../data/models/user_model.dart';
import '../presentation/screens/splash_screen.dart';
import '../presentation/screens/user_list_screen.dart';
import 'app_routes.dart';

class RouteHelper {
  static String getSplashRoute() => AppRoutes.splash;

  static String getUserListRoute() => AppRoutes.userList;

  static String getFavoriteRoute() => AppRoutes.favorite;

  static String getUserDetailsRoute() => AppRoutes.userDetails;

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRoutes.userList:
        return MaterialPageRoute(builder: (_) => const UserListScreen());
      case AppRoutes.favorite:
        return MaterialPageRoute(builder: (_) => const FavoritesScreen());

      case AppRoutes.userDetails:
        final user = settings.arguments as UserModel; // cast arguments
        return MaterialPageRoute(builder: (_) => UserDetailScreen(user: user));

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}
