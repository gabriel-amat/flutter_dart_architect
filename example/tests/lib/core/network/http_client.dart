class HttpResponse<T> {
  final T data;
  final int statusCode;
  final Map<String, dynamic>? headers;

  const HttpResponse({
    required this.data,
    required this.statusCode,
    this.headers,
  });
}

class HttpNetworkException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const HttpNetworkException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => 'HttpNetworkException: $message (status: $statusCode)';
}

abstract interface class IHttpClient {
  Future<HttpResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  });

  Future<HttpResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  });
}
