part of 'login_controller.dart';

/// Sealed State representations for compile-time exhaustive UI matching.
sealed class LoginState {
  const LoginState();
}

final class LoginInitial extends LoginState {
  const LoginInitial();
}

final class LoginLoading extends LoginState {
  const LoginLoading();
}

final class LoginSuccess extends LoginState {
  final UserEntity user;
  const LoginSuccess(this.user);
}

final class LoginError extends LoginState {
  final String message;
  const LoginError(this.message);
}
