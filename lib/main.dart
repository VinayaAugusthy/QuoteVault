import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'core/constants/api_constants.dart';
import 'core/di/injection_container.dart';
import 'features/settings/presentation/cubit/settings_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: ApiConstants.supabaseUrl,
    anonKey: ApiConstants.supabaseAnonKey,
  );

  final container = InjectionContainer();
  final mergedSettings = await container.settingsRepository.loadMerged();
  final initialSettings = SettingsState.fromSettings(
    mergedSettings,
    initialized: true,
  );

  runApp(QuoteVaultApp(initialSettings: initialSettings));
}
