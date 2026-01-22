import '../repositories/auth_repository.dart';

class ExchangeCodeForSessionUseCase {
  final AuthRepository repository;

  ExchangeCodeForSessionUseCase(this.repository);

  Future<void> call({required String code}) async {
    return await repository.exchangeCodeForSession(code: code);
  }
}
