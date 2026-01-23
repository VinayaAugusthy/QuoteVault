import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/settings_repository.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository settingsRepository;

  Timer? _remoteDebounce;
  bool _loading = false;

  SettingsCubit({required this.settingsRepository, SettingsState? initialState})
    : super(initialState ?? SettingsState.defaults());

  @override
  Future<void> close() {
    _remoteDebounce?.cancel();
    return super.close();
  }

  Future<void> loadSettings() async {
    if (_loading) return;
    _loading = true;
    try {
      final merged = await settingsRepository.loadMerged();
      emit(SettingsState.fromSettings(merged, initialized: true));
    } finally {
      _loading = false;
    }
  }

  Future<void> toggleTheme(ThemeMode mode) async {
    final next = state.copyWith(themeMode: mode, initialized: true);
    emit(next);
    await _persistLocalAndRemote(next, debounceRemote: false);
  }

  Future<void> changeAccentColor(String color) async {
    final next = state.copyWith(accentColor: color, initialized: true);
    emit(next);
    await _persistLocalAndRemote(next, debounceRemote: false);
  }

  Future<void> changeFontScale(double scale) async {
    final clamped = scale.clamp(0.8, 1.4).toDouble();
    final next = state.copyWith(fontScale: clamped, initialized: true);
    emit(next);
    await _persistLocalAndRemote(next, debounceRemote: true);
  }

  Future<void> _persistLocalAndRemote(
    SettingsState next, {
    required bool debounceRemote,
  }) async {
    await settingsRepository.saveLocal(next.toSettings());

    if (!debounceRemote) {
      _remoteDebounce?.cancel();
      await settingsRepository.saveRemote(next.toSettings());
      return;
    }

    _remoteDebounce?.cancel();
    _remoteDebounce = Timer(const Duration(milliseconds: 450), () async {
      try {
        await settingsRepository.saveRemote(next.toSettings());
      } catch (_) {
        debugPrint('SettingsCubit: remote sync failed (ignored).');
      }
    });
  }
}
