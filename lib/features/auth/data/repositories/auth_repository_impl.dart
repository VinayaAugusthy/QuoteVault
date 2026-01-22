import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final userModel = await remoteDataSource.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
      return userModel;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User> signIn({required String email, required String password}) async {
    try {
      final userModel = await remoteDataSource.signIn(
        email: email,
        password: password,
      );
      return userModel;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await remoteDataSource.signOut();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await remoteDataSource.resetPassword(email: email);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> exchangeCodeForSession({required String code}) async {
    try {
      await remoteDataSource.exchangeCodeForSession(code: code);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> updatePassword({required String newPassword}) async {
    try {
      await remoteDataSource.updatePassword(newPassword: newPassword);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      return await remoteDataSource.getCurrentUser();
    } catch (e) {
      return null;
    }
  }

  @override
  Stream get authStateChanges => remoteDataSource.authStateChanges;
}
