import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/user_settings.dart';
import '../models/settings_model.dart';

abstract class SettingsRemoteDataSource {
  Future<UserSettings?> fetchSettings({
    required String userId,
    required UserSettings fallback,
  });
  Future<void> upsertSettings({
    required String userId,
    required UserSettings settings,
  });
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final SupabaseClient supabaseClient;

  SettingsRemoteDataSourceImpl({required this.supabaseClient});

  static const _table = 'profiles';

  @override
  Future<UserSettings?> fetchSettings({
    required String userId,
    required UserSettings fallback,
  }) async {
    try {
      final result = await supabaseClient
          .from(_table)
          .select('theme_mode, accent_color, font_scale')
          .eq('id', userId)
          .maybeSingle();

      if (result == null) return null;

      return SettingsModel.fromMap(result, fallback: fallback);
    } on PostgrestException {
      debugPrint(
        'SettingsRemoteDataSource.fetchSettings failed (profiles missing/RLS?): falling back to local.',
      );
      return null;
    }
  }

  @override
  Future<void> upsertSettings({
    required String userId,
    required UserSettings settings,
  }) async {
    final model = SettingsModel(
      themeMode: settings.themeMode,
      accentColor: settings.accentColor,
      fontScale: settings.fontScale,
    );
    final payload = <String, dynamic>{'id': userId, ...model.toRemoteMap()};
    try {
      await supabaseClient.from(_table).upsert(payload, onConflict: 'id');
    } on PostgrestException {
      debugPrint(
        'SettingsRemoteDataSource.upsertSettings failed (profiles missing/RLS?): ignoring.',
      );
    }
  }
}
