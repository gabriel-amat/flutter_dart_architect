import '../../../../core/error/either.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/http_client.dart';
import '../../../../core/network/http_network_exception.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/auth_datasource.dart';
import '../models/user_model.dart';

/// Concrete Repository implementation orchestrating serialization, data transport,
/// and mapping HttpNetworkException to domain Failures.
class AuthRepository implements IAuthRepository {
  final AuthDatasource _datasource;
  final IHttpClient _client;

  AuthRepository(this._datasource, this._client);

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final payload = {
        'email': email,
        'password': password,
      };

      final response = await _datasource.login(payload);
      final rawData = response.data;

      if (rawData is! Map) {
        return const Left(ServerFailure(message: 'Resposta inesperada do servidor.'));
      }

      final user = UserModel.fromJson(Map<String, dynamic>.from(rawData));
      
      // Update authenticated session
      _client.setToken(user.token);

      return Right(user);
    } on HttpNetworkException catch (e) {
      if (e.isUnauthorized) {
        return Left(UnauthorizedFailure(message: e.message));
      }
      if (e.isConnectionError) {
        return Left(ConnectionFailure(message: e.message));
      }
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e, st) {
      return Left(UnknownFailure(message: e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _datasource.logout();
      _client.clearTokens();
      return const Right(unit);
    } on HttpNetworkException catch (e) {
      _client.clearTokens();
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e, st) {
      _client.clearTokens();
      return Left(UnknownFailure(message: e.toString(), stackTrace: st));
    }
  }
}
