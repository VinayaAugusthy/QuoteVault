import 'package:flutter/material.dart';

class UserSettings {
  final ThemeMode themeMode;
  final String accentColor; // 'teal' | 'red' | 'indigo'
  final double fontScale; // 0.8 .. 1.4

  const UserSettings({
    required this.themeMode,
    required this.accentColor,
    required this.fontScale,
  });

  UserSettings copyWith({
    ThemeMode? themeMode,
    String? accentColor,
    double? fontScale,
  }) {
    return UserSettings(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      fontScale: fontScale ?? this.fontScale,
    );
  }
}
