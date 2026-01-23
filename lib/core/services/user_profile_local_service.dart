import 'package:shared_preferences/shared_preferences.dart';

class UserProfileLocalService {
  static const _avatarPathPrefix = 'profile_avatar_path__';

  static String _avatarKey(String userId) => '$_avatarPathPrefix$userId';

  static Future<String?> getAvatarPath(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_avatarKey(userId));
  }

  static Future<void> setAvatarPath(String userId, String? path) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _avatarKey(userId);
    if (path == null || path.trim().isEmpty) {
      await prefs.remove(key);
      return;
    }
    await prefs.setString(key, path);
  }
}


