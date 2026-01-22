import 'package:flutter/material.dart';
import 'package:quote_vault/core/constants/app_colors.dart';

class SnackbarUtils {
  SnackbarUtils._();

  static void showWithMessenger(
    ScaffoldMessengerState? messenger,
    String message, {
    required Color backgroundColor,
  }) {
    if (messenger == null) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Shows an error snackbar with red background
  static void showError(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    showWithMessenger(messenger, message, backgroundColor: AppColors.errorRed);
  }

  /// Shows a success snackbar with green background
  static void showSuccess(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    showWithMessenger(
      messenger,
      message,
      backgroundColor: AppColors.successGreen,
    );
  }
}
