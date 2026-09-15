import '../../../../core/network/http_client.dart';
import '../../../../core/network/http_response.dart';

/// Concrete DataSource solely responsible for raw HTTP transport.
/// Does NOT contain try/catch, model deserialization, or business logic.
class AuthDatasource {
  final IHttpClient _client;

  AuthDatasource(this._client);

  Future<HttpResponse<dynamic>> login(Map<String, dynamic> payload) {
    return _client.post(
      '/auth/login',
      data: payload,
      extra: {'noAuth': true},
    );
  }

  Future<HttpResponse<dynamic>> logout() {
    return _client.post('/auth/logout');
  }
}
