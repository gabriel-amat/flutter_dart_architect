import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';

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

/// Simple controller managing LoginState.
class LoginController extends ValueNotifier<LoginState> {
  final LoginUseCase _loginUseCase;

  LoginController(this._loginUseCase) : super(const LoginInitial());

  Future<void> login({required String email, required String password}) async {
    value = const LoginLoading();

    final result = await _loginUseCase(email: email, password: password);

    result.fold(
      (failure) => value = LoginError(failure.message),
      (user) => value = LoginSuccess(user),
    );
  }
}
