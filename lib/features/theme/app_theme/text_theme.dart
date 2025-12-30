import 'package:flutter/material.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/app_colors.dart';

class AppTextTheme {
  static TextTheme lightTextTheme = TextTheme(
    // Display styles - Large headings
    displayLarge: TextStyle(
      fontSize: Dimensions.font24,
      fontWeight: FontWeight.w700,
      color: AppColors.textColorPrimary,
      letterSpacing: -0.5,
      height: 1.2,
    ),
    displayMedium: TextStyle(
      fontSize: Dimensions.font20,
      fontWeight: FontWeight.w600,
      color: AppColors.textColorPrimary,
      letterSpacing: -0.3,
      height: 1.3,
    ),
    displaySmall: TextStyle(
      fontSize: Dimensions.font18,
      fontWeight: FontWeight.w600,
      color: AppColors.textColorPrimary,
      letterSpacing: -0.2,
      height: 1.3,
    ),

    // Headline styles
    headlineLarge: TextStyle(
      fontSize: Dimensions.font18,
      fontWeight: FontWeight.w600,
      color: AppColors.textColorPrimary,
      letterSpacing: -0.2,
    ),
    headlineMedium: TextStyle(
      fontSize: Dimensions.font16,
      fontWeight: FontWeight.w600,
      color: AppColors.textColorPrimary,
      letterSpacing: -0.2,
    ),
    headlineSmall: TextStyle(
      fontSize: Dimensions.font14,
      fontWeight: FontWeight.w600,
      color: AppColors.textColorPrimary,
      letterSpacing: -0.1,
    ),

    // Title styles
    titleLarge: TextStyle(
      fontSize: Dimensions.font16,
      fontWeight: FontWeight.w600,
      color: AppColors.textColorPrimary,
      letterSpacing: -0.2,
      height: 1.4,
    ),
    titleMedium: TextStyle(
      fontSize: Dimensions.font14,
      fontWeight: FontWeight.w600,
      color: AppColors.textColorPrimary,
      letterSpacing: -0.1,
      height: 1.4,
    ),
    titleSmall: TextStyle(
      fontSize: Dimensions.font12,
      fontWeight: FontWeight.w600,
      color: AppColors.textColorPrimary,
      letterSpacing: 0,
      height: 1.4,
    ),

    // Body styles
    bodyLarge: TextStyle(
      fontSize: Dimensions.font16,
      fontWeight: FontWeight.w400,
      color: AppColors.textColorPrimary,
      letterSpacing: -0.1,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: Dimensions.font14,
      fontWeight: FontWeight.w400,
      color: AppColors.textColorSecondary,
      letterSpacing: 0,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontSize: Dimensions.font12,
      fontWeight: FontWeight.w400,
      color: AppColors.textColorSecondary,
      letterSpacing: 0,
      height: 1.4,
    ),

    // Label styles - for buttons, chips, etc.
    labelLarge: TextStyle(
      fontSize: Dimensions.font14,
      fontWeight: FontWeight.w600,
      color: AppColors.textColorPrimary,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontSize: Dimensions.font12,
      fontWeight: FontWeight.w500,
      color: AppColors.textColorSecondary,
      letterSpacing: 0.1,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: AppColors.textColorHint,
      letterSpacing: 0.2,
    ),
  );

  static TextTheme darkTextTheme = TextTheme(
    // Display styles - Large headings
    displayLarge: TextStyle(
      fontSize: Dimensions.font24,
      fontWeight: FontWeight.w700,
      color: AppColors.darkTextColorPrimary,
      letterSpacing: -0.5,
      height: 1.2,
    ),
    displayMedium: TextStyle(
      fontSize: Dimensions.font20,
      fontWeight: FontWeight.w600,
      color: AppColors.darkTextColorPrimary,
      letterSpacing: -0.3,
      height: 1.3,
    ),
    displaySmall: TextStyle(
      fontSize: Dimensions.font18,
      fontWeight: FontWeight.w600,
      color: AppColors.darkTextColorPrimary,
      letterSpacing: -0.2,
      height: 1.3,
    ),

    // Headline styles
    headlineLarge: TextStyle(
      fontSize: Dimensions.font18,
      fontWeight: FontWeight.w600,
      color: AppColors.darkTextColorPrimary,
      letterSpacing: -0.2,
    ),
    headlineMedium: TextStyle(
      fontSize: Dimensions.font16,
      fontWeight: FontWeight.w600,
      color: AppColors.darkTextColorPrimary,
      letterSpacing: -0.2,
    ),
    headlineSmall: TextStyle(
      fontSize: Dimensions.font14,
      fontWeight: FontWeight.w600,
      color: AppColors.darkTextColorPrimary,
      letterSpacing: -0.1,
    ),

    // Title styles
    titleLarge: TextStyle(
      fontSize: Dimensions.font16,
      fontWeight: FontWeight.w600,
      color: AppColors.darkTextColorPrimary,
      letterSpacing: -0.2,
      height: 1.4,
    ),
    titleMedium: TextStyle(
      fontSize: Dimensions.font14,
      fontWeight: FontWeight.w600,
      color: AppColors.darkTextColorPrimary,
      letterSpacing: -0.1,
      height: 1.4,
    ),
    titleSmall: TextStyle(
      fontSize: Dimensions.font12,
      fontWeight: FontWeight.w600,
      color: AppColors.darkTextColorPrimary,
      letterSpacing: 0,
      height: 1.4,
    ),

    // Body styles
    bodyLarge: TextStyle(
      fontSize: Dimensions.font16,
      fontWeight: FontWeight.w400,
      color: AppColors.darkTextColorPrimary,
      letterSpacing: -0.1,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: Dimensions.font14,
      fontWeight: FontWeight.w400,
      color: AppColors.darkTextColorSecondary,
      letterSpacing: 0,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontSize: Dimensions.font12,
      fontWeight: FontWeight.w400,
      color: AppColors.darkTextColorSecondary,
      letterSpacing: 0,
      height: 1.4,
    ),

    // Label styles - for buttons, chips, etc.
    labelLarge: TextStyle(
      fontSize: Dimensions.font14,
      fontWeight: FontWeight.w600,
      color: AppColors.darkTextColorPrimary,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontSize: Dimensions.font12,
      fontWeight: FontWeight.w500,
      color: AppColors.darkTextColorSecondary,
      letterSpacing: 0.1,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: AppColors.darkTextColorHint,
      letterSpacing: 0.2,
    ),
  );
}