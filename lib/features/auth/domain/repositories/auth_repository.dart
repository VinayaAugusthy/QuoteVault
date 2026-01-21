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
  Future<User?> getCurrentUser();
  Stream get authStateChanges;
}
