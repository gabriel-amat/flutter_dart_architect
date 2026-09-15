import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';

part 'login_state.dart';

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
