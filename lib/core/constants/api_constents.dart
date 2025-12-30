import 'app_constants.dart';

class ApiConstants {
  // Base URL
  static String baseUrl = AppConstants.baseUrl;

  // API
  static const String apiVersion = '/api';

  // -------------------- Authentication --------------------
  static const String sendOtp = '$apiVersion/auth/send-otp';
  static const String verifyOtp = '$apiVersion/auth/verify-otp';
  static const String logout = '$apiVersion/auth/logout';

  // -------------------- Upload Files -----------------
  static const String uploadFile = '$apiVersion/file/upload';


  // -------------------- User --------------------
  static const String getUserProfile = '$apiVersion/auth/me';
  static const String updateUserProfile = '$apiVersion/auth/profile';

  // -------------------- Settings --------------------
  static const String languages = '$apiVersion/languages';
  static const String themes = '$apiVersion/themes';
}
