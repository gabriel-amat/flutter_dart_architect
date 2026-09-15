import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_examples/core/network/http_client.dart';
import 'package:flutter_testing_examples/datasources/user_datasource.dart';

class FakeHttpClient implements IHttpClient {
  String? lastGetPath;
  String? lastPostPath;
  dynamic lastPostData;
  HttpResponse<dynamic>? responseToReturn;
  Object? exceptionToThrow;

  @override
  Future<HttpResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    lastGetPath = path;
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return responseToReturn! as HttpResponse<T>;
  }

  @override
  Future<HttpResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    lastPostPath = path;
    lastPostData = data;
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return responseToReturn! as HttpResponse<T>;
  }
}

void main() {
  late FakeHttpClient fakeClient;
  late UserDataSource dataSource;

  setUp(() {
    fakeClient = FakeHttpClient();
    dataSource = UserDataSource(client: fakeClient);
  });

  group('DataSource Test: Concrete HTTP Transportation (No Try/Catch)', () {
    test('getUserById should hit GET /users/{id} and return raw HttpResponse', () async {
      fakeClient.responseToReturn = const HttpResponse(
        data: {'id': '42', 'name': 'Arthur Dent', 'email': 'arthur@galaxy.org'},
        statusCode: 200,
      );

      final response = await dataSource.getUserById('42');

      expect(fakeClient.lastGetPath, '/users/42');
      expect(response.statusCode, 200);
      expect((response.data as Map)['name'], 'Arthur Dent');
    });

    test('updateScore should hit POST /users/{id}/score with data payload', () async {
      fakeClient.responseToReturn = const HttpResponse(
        data: {'success': true},
        statusCode: 200,
      );

      await dataSource.updateScore('42', 999);

      expect(fakeClient.lastPostPath, '/users/42/score');
      expect(fakeClient.lastPostData, {'score': 999});
    });

    test('should allow HttpNetworkException to bubble up directly without swallowing', () async {
      fakeClient.exceptionToThrow = const HttpNetworkException(
        message: 'Unauthorized',
        statusCode: 401,
      );

      expect(
        () => dataSource.getUserById('99'),
        throwsA(isA<HttpNetworkException>()),
      );
    });
  });
}
