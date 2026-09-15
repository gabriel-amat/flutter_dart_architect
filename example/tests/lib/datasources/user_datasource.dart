import '../core/network/http_client.dart';

/// Concrete DataSource executing raw transport via [IHttpClient].
/// Zero try/catch here, as defined in the Clean Architecture specification.
class UserDataSource {
  final IHttpClient _client;

  const UserDataSource({required IHttpClient client}) : _client = client;

  Future<HttpResponse<dynamic>> getUserById(String id) {
    return _client.get('/users/$id');
  }

  Future<HttpResponse<dynamic>> updateScore(String id, int score) {
    return _client.post('/users/$id/score', data: {'score': score});
  }
}
