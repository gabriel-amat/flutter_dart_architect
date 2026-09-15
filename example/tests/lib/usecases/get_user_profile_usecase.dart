import '../core/error/either.dart';
import '../core/error/failure.dart';
import '../models/user_model.dart';
import '../repositories/user_repository_impl.dart';

class GetUserProfileUseCase {
  final IUserRepository _repository;

  const GetUserProfileUseCase({required IUserRepository repository})
      : _repository = repository;

  Future<Either<Failure, UserModel>> call(String userId) async {
    if (userId.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty.'));
    }
    return _repository.getUser(userId.trim());
  }
}
