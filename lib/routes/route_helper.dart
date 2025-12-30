// lib/routes/route_helper.dart

import 'package:flutter/material.dart';
import '../features/auth/view/login_screen.dart';
import '../features/auth/view/otp_screen.dart';
import '../features/auth/view/profile_setup_screen.dart';
import '../features/home/home.dart';
import '../features/splash/splash_screen.dart';

class RouteHelper {
  // Route Names
  static const String splash = '/splash';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String profileSetup = '/profile-setup';
  static const String home = '/home';

  // Route Getters
  static String getSplashRoute() => splash;
  static String getLoginRoute() => login;
  static String getOtpRoute() => otp;
  static String getProfileSetupRoute() => profileSetup;
  static String getHomeRoute() => home;

  // Route Generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case otp:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null && args['phoneNumber'] != null) {
          return MaterialPageRoute(
            builder: (_) => OtpScreen(
              phoneNumber: args['phoneNumber'],
            ),
          );
        }
        return _errorRoute();

      case profileSetup:
        return MaterialPageRoute(
          builder: (_) => const ProfileSetupScreen(),
        );

      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );

      default:
        return _errorRoute();
    }
  }

  // Error Route
  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(
          child: Text('Route not found'),
        ),
      ),
    );
  }
}