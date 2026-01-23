import 'package:flutter/material.dart';
import 'package:quote_vault/core/constants/app_strings.dart';

class ErrorDisplayWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorDisplayWidget({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message),
          if (onRetry != null)
            ElevatedButton(
              onPressed: onRetry,
              child: const Text(AppStrings.retry),
            ),
        ],
      ),
    );
  }
}
