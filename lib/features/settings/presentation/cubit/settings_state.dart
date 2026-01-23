import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/user_settings.dart';

class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final String accentColor;
  final double fontScale;

  /// Used to prevent startup flicker/rebuild loops while settings are loading.
  final bool initialized;

  const SettingsState({
    required this.themeMode,
    required this.accentColor,
    required this.fontScale,
    this.initialized = false,
  });

  factory SettingsState.defaults() => const SettingsState(
    themeMode: ThemeMode.light,
    accentColor: 'teal',
    fontScale: 1.0,
    initialized: false,
  );

  factory SettingsState.fromSettings(
    UserSettings settings, {
    bool initialized = true,
  }) {
    return SettingsState(
      themeMode: settings.themeMode,
      accentColor: settings.accentColor,
      fontScale: settings.fontScale,
      initialized: initialized,
    );
  }

  UserSettings toSettings() => UserSettings(
    themeMode: themeMode,
    accentColor: accentColor,
    fontScale: fontScale,
  );

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? accentColor,
    double? fontScale,
    bool? initialized,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      fontScale: fontScale ?? this.fontScale,
      initialized: initialized ?? this.initialized,
    );
  }

  @override
  List<Object?> get props => [themeMode, accentColor, fontScale, initialized];
}
