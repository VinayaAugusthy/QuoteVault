import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signUp({
    required String email,
    required String password,
    String? fullName,
  });
  Future<UserModel> signIn({required String email, required String password});
  Future<void> signOut();
  Future<void> resetPassword({required String email});
  Future<void> exchangeCodeForSession({required String code});
  Future<void> updatePassword({required String newPassword});
  Future<UserModel?> getCurrentUser();
  Stream<AuthState> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );

      if (response.user == null) {
        throw Exception('Failed to create user');
      }
      if (response.user?.identities == null ||
          response.user!.identities!.isEmpty) {
        // Email already exists
        await supabaseClient.auth.signOut(); // prevent auto-login
        throw Exception('Email already exists. Please sign in.');
      }
      return UserModel.fromSupabaseUser(response.user!);
    } on AuthException catch (e) {
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Failed to sign in');
      }

      return UserModel.fromSupabaseUser(response.user!);
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await supabaseClient.auth.resetPasswordForEmail(
        email,
        redirectTo: 'quotevault://reset-password',
      );
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  @override
  Future<void> exchangeCodeForSession({required String code}) async {
    try {
      await supabaseClient.auth.exchangeCodeForSession(code);
    } catch (e) {
      throw Exception('Failed to exchange code for session: ${e.toString()}');
    }
  }

  @override
  Future<void> updatePassword({required String newPassword}) async {
    try {
      await supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      final message = e.message.toLowerCase();
      if (message.contains('session') || message.contains('token')) {
        throw Exception(
          'Password reset session expired or invalid. Please request a new reset link.',
        );
      }
      throw Exception('Password update failed: ${e.message}');
    } catch (e) {
      throw Exception('Password update failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) return null;
      return UserModel.fromSupabaseUser(user);
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<AuthState> get authStateChanges {
    return supabaseClient.auth.onAuthStateChange;
  }
}
