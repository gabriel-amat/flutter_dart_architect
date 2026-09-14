import 'http_response.dart';

/// Decoupled abstract interface class for network communication.
/// Domain and DataSources depend ONLY on this interface, never on Dio.
abstract interface class IHttpClient {
  Future<HttpResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? headers,
    dynamic extra,
  });

  Future<HttpResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? headers,
    dynamic extra,
  });

  Future<HttpResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? headers,
    dynamic extra,
  });

  Future<HttpResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? headers,
    dynamic extra,
  });

  Future<HttpResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? headers,
    dynamic extra,
  });

  void setToken(String? token);
  void setRefreshToken(String? refreshToken);
  void clearTokens();
  String? get token;
  String? get refreshToken;
  bool get isAuthenticated;
  void setOnTokenExpiredCallback(void Function()? callback);
}
