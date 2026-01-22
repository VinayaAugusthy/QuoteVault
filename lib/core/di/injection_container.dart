import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/update_password_usecase.dart';
import '../../features/auth/domain/usecases/exchange_code_for_session_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

class InjectionContainer {
  static final InjectionContainer _instance = InjectionContainer._internal();
  factory InjectionContainer() => _instance;
  InjectionContainer._internal();

  // Supabase Client
  SupabaseClient get supabaseClient => Supabase.instance.client;

  // Data Sources
  AuthRemoteDataSource get authRemoteDataSource =>
      AuthRemoteDataSourceImpl(supabaseClient: supabaseClient);

  // Repositories
  AuthRepository get authRepository =>
      AuthRepositoryImpl(remoteDataSource: authRemoteDataSource);

  // Use Cases
  LoginUseCase get loginUseCase => LoginUseCase(authRepository);
  RegisterUseCase get registerUseCase => RegisterUseCase(authRepository);
  LogoutUseCase get logoutUseCase => LogoutUseCase(authRepository);
  ForgotPasswordUseCase get forgotPasswordUseCase =>
      ForgotPasswordUseCase(authRepository);
  GetCurrentUserUseCase get getCurrentUserUseCase =>
      GetCurrentUserUseCase(authRepository);
  UpdatePasswordUseCase get updatePasswordUseCase =>
      UpdatePasswordUseCase(authRepository);
  ExchangeCodeForSessionUseCase get exchangeCodeForSessionUseCase =>
      ExchangeCodeForSessionUseCase(authRepository);

  // BLoCs
  AuthBloc get authBloc => AuthBloc(
    loginUseCase: loginUseCase,
    registerUseCase: registerUseCase,
    logoutUseCase: logoutUseCase,
    forgotPasswordUseCase: forgotPasswordUseCase,
    getCurrentUserUseCase: getCurrentUserUseCase,
    updatePasswordUseCase: updatePasswordUseCase,
    exchangeCodeForSessionUseCase: exchangeCodeForSessionUseCase,
  );
}
