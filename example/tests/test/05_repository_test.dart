import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_examples/core/error/failure.dart';
import 'package:flutter_testing_examples/core/network/http_client.dart';
import 'package:flutter_testing_examples/datasources/user_datasource.dart';
import 'package:flutter_testing_examples/repositories/user_repository_impl.dart';

class FakeUserDataSource implements UserDataSource {
  HttpResponse<dynamic>? response;
  Object? exceptionToThrow;

  @override
  Future<HttpResponse<dynamic>> getUserById(String id) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return response!;
  }

  @override
  Future<HttpResponse<dynamic>> updateScore(String id, int score) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return response!;
  }
}

void main() {
  late FakeUserDataSource fakeDataSource;
  late UserRepositoryImpl repository;

  setUp(() {
    fakeDataSource = FakeUserDataSource();
    repository = UserRepositoryImpl(dataSource: fakeDataSource);
  });

  group('Repository Test: Translation & Error Mapping', () {
    test('should map 200 JSON payload to Right(UserModel)', () async {
      fakeDataSource.response = const HttpResponse(
        data: {'id': '10', 'name': 'Commander Shepard', 'email': 'shepard@normandy.com', 'score': 900},
        statusCode: 200,
      );

      final result = await repository.getUser('10');

      expect(result.isRight, isTrue);
      expect(result.rightOrNull?.name, 'Commander Shepard');
      expect(result.rightOrNull?.score, 900);
    });

    test('should translate HttpNetworkException 404 into Left(NotFoundFailure)', () async {
      fakeDataSource.exceptionToThrow = const HttpNetworkException(
        message: 'Not found',
        statusCode: 404,
      );

      final result = await repository.getUser('unknown');

      expect(result.isLeft, isTrue);
      expect(result.leftOrNull, isA<NotFoundFailure>());
      expect(result.leftOrNull?.message, 'User profile not found.');
    });

    test('should translate generic 500 error into Left(ServerFailure)', () async {
      fakeDataSource.exceptionToThrow = const HttpNetworkException(
        message: 'Internal error',
        statusCode: 500,
      );

      final result = await repository.getUser('error-id');

      expect(result.isLeft, isTrue);
      expect(result.leftOrNull, isA<ServerFailure>());
      expect(result.leftOrNull?.statusCode, 500);
    });
  });
}
