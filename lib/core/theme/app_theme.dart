import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static const _accentTeal = 'teal';
  static const _accentRed = 'red';
  static const _accentIndigo = 'indigo';

  static const supportedAccents = <String>[
    _accentTeal,
    _accentRed,
    _accentIndigo,
  ];

  static Color seedColorFor(String accent) {
    switch (accent.toLowerCase()) {
      case _accentRed:
        return AppColors.primaryRed;
      case _accentIndigo:
        return AppColors.primaryIndigo;
      case _accentTeal:
      default:
        return AppColors.primaryTeal;
    }
  }

  static ThemeData light(String accent) {
    final seed = seedColorFor(accent);
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  static ThemeData dark(String accent) {
    final seed = seedColorFor(accent);
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
