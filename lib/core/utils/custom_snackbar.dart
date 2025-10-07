import 'package:flutter/material.dart';
import 'package:softfix_user/core/services/translations/localization_extension.dart';
import '../../main.dart';
import '../theme/app_colors.dart';

class CustomSnackbar {
  static void _show({
    required String title,
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Color? textColor,
  }) {
    final context = rootScaffoldMessengerKey.currentContext;
    if (context == null) return;

    final Color effectiveTextColor =
        textColor ??
            (backgroundColor.computeLuminance() > 0.5
                ? Colors.black
                : Colors.white);

    final snackBar = SnackBar(
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 3),
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: effectiveTextColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title.trGlobal, // ✅ using global translation
                  style: TextStyle(
                    color: effectiveTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message.trGlobal, // ✅ using global translation
                  style: TextStyle(color: effectiveTextColor, fontSize: 14),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () =>
                rootScaffoldMessengerKey.currentState?.hideCurrentSnackBar(),
            child: Text(
              "DISMISS".trGlobal, // optional: translate this too
              style: TextStyle(
                color: effectiveTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    rootScaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }

  static void showSuccess(String message, {String title = 'Success'}) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.successColor,
      icon: Icons.check_circle,
    );
  }

  static void showError(String message, {String title = 'Error'}) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.errorColor,
      icon: Icons.error,
    );
  }

  static void showInfo(String message, {String title = 'Info'}) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.infoColor,
      icon: Icons.info,
    );
  }

  static void showWarning(String message, {String title = 'Warning'}) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.warningColor,
      icon: Icons.warning,
    );
  }

  static void showFavoriteStatus({
    required bool isFavorite,
  }) {
    final title = 'Favorites'.trGlobal;

    final message = !isFavorite
        ? 'Added to favorites'.trGlobal
        : 'Removed from favorites'.trGlobal;

    final Color backgroundColor = !isFavorite
        ? AppColors.successColor.withOpacity(0.9)
        : AppColors.errorColor.withOpacity(0.9);

    final IconData icon = !isFavorite ? Icons.favorite : Icons.favorite_border;

    _show(
      title: title,
      message: message,
      backgroundColor: backgroundColor,
      icon: icon,
    );
  }
}
