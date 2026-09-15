import '../core/error/either.dart';
import '../core/error/failure.dart';
import '../core/network/http_client.dart';
import '../datasources/user_datasource.dart';
import '../models/user_model.dart';

abstract interface class IUserRepository {
  Future<Either<Failure, UserModel>> getUser(String id);
  Future<Either<Failure, void>> updateScore(String id, int newScore);
}

class UserRepositoryImpl implements IUserRepository {
  final UserDataSource _dataSource;

  const UserRepositoryImpl({required UserDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Either<Failure, UserModel>> getUser(String id) async {
    try {
      final response = await _dataSource.getUserById(id);
      final model = UserModel.fromJson(response.data as Map<String, dynamic>);
      return Right(model);
    } on HttpNetworkException catch (e) {
      if (e.statusCode == 404) {
        return const Left(NotFoundFailure(message: 'User profile not found.'));
      }
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateScore(String id, int newScore) async {
    try {
      await _dataSource.updateScore(id, newScore);
      return const Right(null);
    } on HttpNetworkException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }
}
