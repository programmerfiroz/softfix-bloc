import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../text_theme.dart';

ThemeData blueTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.bluePrimaryColor,
  scaffoldBackgroundColor: AppColors.scaffoldBackgroundColor,
  colorScheme: ColorScheme.light(
    primary: AppColors.bluePrimaryColor,
    secondary: AppColors.blueSecondaryColor,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    background: AppColors.backgroundColor,
    surface: AppColors.cardColor,
    error: AppColors.errorColor,
  ),
  cardColor: AppColors.cardColor,
  dividerColor: AppColors.dividerColor,
  textTheme: AppTextTheme.lightTextTheme,
  appBarTheme: AppBarTheme(
    elevation: 0,
    color: AppColors.bluePrimaryColor,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: Colors.white,
    filled: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.bluePrimaryColor, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.errorColor),
    ),
    hintStyle: TextStyle(color: AppColors.textColorHint),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.bluePrimaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
    ),
  ),
);

