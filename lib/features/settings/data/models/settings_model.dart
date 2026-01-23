import 'package:flutter/material.dart';

import '../../domain/entities/user_settings.dart';

class SettingsModel extends UserSettings {
  const SettingsModel({
    required super.themeMode,
    required super.accentColor,
    required super.fontScale,
  });

  static ThemeMode _parseThemeMode(Object? value) {
    final v = (value as String?)?.toLowerCase();
    switch (v) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      case 'light':
      default:
        return ThemeMode.light;
    }
  }

  static String _encodeThemeMode(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
      ThemeMode.light => 'light',
    };
  }

  static double _parseDouble(Object? value, {required double fallback}) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  factory SettingsModel.fromMap(
    Map<String, dynamic> map, {
    required UserSettings fallback,
  }) {
    return SettingsModel(
      themeMode: _parseThemeMode(map['theme_mode'] ?? map['themeMode']),
      accentColor:
          (map['accent_color'] ?? map['accentColor'] ?? fallback.accentColor)
              .toString(),
      fontScale: _parseDouble(
        map['font_scale'] ?? map['fontScale'],
        fallback: fallback.fontScale,
      ),
    );
  }

  Map<String, dynamic> toLocalMap() => <String, dynamic>{
    'themeMode': _encodeThemeMode(themeMode),
    'accentColor': accentColor,
    'fontScale': fontScale,
  };

  Map<String, dynamic> toRemoteMap() => <String, dynamic>{
    'theme_mode': _encodeThemeMode(themeMode),
    'accent_color': accentColor,
    'font_scale': fontScale,
  };
}
