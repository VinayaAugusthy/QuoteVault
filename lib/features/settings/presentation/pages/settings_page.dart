import 'package:flutter/material.dart';
import 'package:quote_vault/core/constants/app_colors.dart';
import 'package:quote_vault/core/constants/app_strings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        title: const Text(AppStrings.navSettings),
        centerTitle: true,
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
      ),
      body: const Center(child: Text(AppStrings.settingsPagePlaceholder)),
    );
  }
}
