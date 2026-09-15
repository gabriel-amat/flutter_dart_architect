library core_network;

/// Generic response wrapper exposed to all feature packages
class CoreHttpResponse<T> {
  final T? data;
  final int? statusCode;
  const CoreHttpResponse({this.data, this.statusCode});
}

/// Abstract contract for HTTP operations.
abstract interface class ICoreHttpClient {
  Future<CoreHttpResponse<T>> get<T>(String path, {Map<String, dynamic>? queryParams});
  Future<CoreHttpResponse<T>> post<T>(String path, {dynamic data});
}
