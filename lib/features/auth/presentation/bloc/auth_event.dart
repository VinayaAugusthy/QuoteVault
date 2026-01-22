part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

final class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

final class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String? fullName;

  const RegisterRequested({
    required this.email,
    required this.password,
    this.fullName,
  });

  @override
  List<Object> get props => [email, password, fullName ?? ''];
}

final class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

final class ForgotPasswordRequested extends AuthEvent {
  final String email;

  const ForgotPasswordRequested({required this.email});

  @override
  List<Object> get props => [email];
}

final class UpdatePasswordRequested extends AuthEvent {
  final String newPassword;

  const UpdatePasswordRequested({required this.newPassword});

  @override
  List<Object> get props => [newPassword];
}

final class ExchangeCodeForSessionRequested extends AuthEvent {
  final String code;

  const ExchangeCodeForSessionRequested({required this.code});

  @override
  List<Object> get props => [code];
}

final class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}
