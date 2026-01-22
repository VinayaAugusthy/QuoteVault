import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> signUp({
    required String email,
    required String password,
    String? fullName,
  });
  Future<User> signIn({required String email, required String password});
  Future<void> signOut();
  Future<void> resetPassword({required String email});
  Future<void> exchangeCodeForSession({required String code});
  Future<void> updatePassword({required String newPassword});
  Future<User?> getCurrentUser();
  Stream get authStateChanges;
}
