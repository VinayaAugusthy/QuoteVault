import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/user_settings.dart';
import '../models/settings_model.dart';

abstract class SettingsLocalDataSource {
  Future<UserSettings?> getSettings();
  Future<void> saveSettings(UserSettings settings);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  static const _kThemeMode = 'settings.themeMode';
  static const _kAccentColor = 'settings.accentColor';
  static const _kFontScale = 'settings.fontScale';

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  Future<UserSettings?> getSettings() async {
    final prefs = await _prefs;
    final themeMode = prefs.getString(_kThemeMode);
    final accentColor = prefs.getString(_kAccentColor);
    final fontScale = prefs.getDouble(_kFontScale);

    if (themeMode == null && accentColor == null && fontScale == null) {
      return null;
    }

    final fallback = const UserSettings(
      themeMode: ThemeMode.light,
      accentColor: 'teal',
      fontScale: 1.0,
    );
    return SettingsModel.fromMap({
      'themeMode': themeMode,
      'accentColor': accentColor,
      'fontScale': fontScale,
    }, fallback: fallback);
  }

  @override
  Future<void> saveSettings(UserSettings settings) async {
    final prefs = await _prefs;
    final model = SettingsModel(
      themeMode: settings.themeMode,
      accentColor: settings.accentColor,
      fontScale: settings.fontScale,
    );
    final map = model.toLocalMap();
    await prefs.setString(_kThemeMode, map['themeMode'] as String);
    await prefs.setString(_kAccentColor, map['accentColor'] as String);
    await prefs.setDouble(_kFontScale, map['fontScale'] as double);
  }
}
