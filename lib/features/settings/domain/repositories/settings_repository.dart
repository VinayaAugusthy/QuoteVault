import '../entities/user_settings.dart';

abstract class SettingsRepository {
  Future<UserSettings> loadMerged();

  Future<void> saveLocal(UserSettings settings);

  Future<void> saveRemote(UserSettings settings);
}
