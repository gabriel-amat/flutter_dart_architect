import '../../../../core/error/either.dart';
import '../../../../core/error/failure.dart';
import '../entities/user_entity.dart';
import '../repositories/i_auth_repository.dart';

/// Single-responsibility Domain UseCase.
class LoginUseCase {
  final IAuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) {
    if (email.trim().isEmpty || !email.contains('@')) {
      return Future.value(const Left(ValidationFailure(message: 'E-mail inválido.')));
    }
    if (password.length < 6) {
      return Future.value(const Left(ValidationFailure(message: 'A senha deve ter no mínimo 6 caracteres.')));
    }

    return _repository.login(email: email.trim(), password: password);
  }
}
