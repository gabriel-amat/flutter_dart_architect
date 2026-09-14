import '../../../../core/error/either.dart';
import '../../../../core/error/failure.dart';
import '../entities/user_entity.dart';

/// Domain Repository Interface.
abstract interface class IAuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, Unit>> logout();
}
