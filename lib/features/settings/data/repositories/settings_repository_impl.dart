import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/user_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';
import '../datasources/settings_remote_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;
  final SettingsRemoteDataSource remoteDataSource;
  final SupabaseClient supabaseClient;

  SettingsRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.supabaseClient,
  });

  static const UserSettings _defaults = UserSettings(
    themeMode: ThemeMode.light,
    accentColor: 'teal',
    fontScale: 1.0,
  );

  @override
  Future<UserSettings> loadMerged() async {
    final local = await localDataSource.getSettings() ?? _defaults;

    final user = supabaseClient.auth.currentUser;
    if (user == null) {
      await localDataSource.saveSettings(local);
      return local;
    }

    UserSettings? remoteSettings;
    try {
      remoteSettings = await remoteDataSource.fetchSettings(
        userId: user.id,
        fallback: local,
      );
    } catch (e, st) {
      debugPrint('SettingsRepository.loadMerged remote fetch failed: $e\n$st');
    }
    final merged = remoteSettings ?? local;

    await localDataSource.saveSettings(merged);
    return merged;
  }

  @override
  Future<void> saveLocal(UserSettings settings) {
    return localDataSource.saveSettings(settings);
  }

  @override
  Future<void> saveRemote(UserSettings settings) async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) return;
    try {
      await remoteDataSource.upsertSettings(
        userId: user.id,
        settings: settings,
      );
    } catch (e, st) {
      debugPrint('SettingsRepository.saveRemote failed: $e\n$st');
    }
  }
}
