import 'package:dio/dio.dart';
import 'http_client.dart';
import 'http_network_exception.dart';
import 'http_response.dart';
import 'interceptors/auth_interceptor.dart';

/// Production-ready IHttpClient implementation using Dio.
/// Decouples all framework-specific exceptions and converts them into HttpNetworkException.
class DioHttpClient implements IHttpClient {
  final Dio _dio;
  final Dio _cleanDio;

  String? _token;
  String? _refreshToken;
  void Function()? _onTokenExpired;

  DioHttpClient({
    String baseUrl = 'https://api.example.com',
    Dio? dio,
    Dio? cleanDio,
  })  : _dio = dio ?? Dio(),
        _cleanDio = cleanDio ?? Dio() {
    final baseOptions = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    _dio.options = baseOptions.copyWith();
    _cleanDio.options = baseOptions.copyWith();

    _dio.interceptors.add(
      AuthInterceptor(
        getCleanDio: () => _cleanDio,
        getToken: () => _token,
        getRefreshToken: () => _refreshToken,
        onSaveTokens: (token, refreshToken) {
          _token = token;
          _refreshToken = refreshToken;
        },
        onClearTokens: () => clearTokens(),
        onTokenExpired: () => _onTokenExpired?.call(),
      ),
    );
  }

  @override
  String? get token => _token;

  @override
  String? get refreshToken => _refreshToken;

  @override
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  @override
  void setToken(String? token) => _token = token;

  @override
  void setRefreshToken(String? refreshToken) => _refreshToken = refreshToken;

  @override
  void clearTokens() {
    _token = null;
    _refreshToken = null;
  }

  @override
  void setOnTokenExpiredCallback(void Function()? callback) =>
      _onTokenExpired = callback;

  @override
  Future<HttpResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? headers,
    dynamic extra,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParams,
        options: Options(headers: headers, extra: extra as Map<String, dynamic>?),
      );
      return _toHttpResponse<T>(response);
    } on DioException catch (e, st) {
      throw _mapDioException(e, st);
    }
  }

  @override
  Future<HttpResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? headers,
    dynamic extra,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParams,
        options: Options(headers: headers, extra: extra as Map<String, dynamic>?),
      );
      return _toHttpResponse<T>(response);
    } on DioException catch (e, st) {
      throw _mapDioException(e, st);
    }
  }

  @override
  Future<HttpResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? headers,
    dynamic extra,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParams,
        options: Options(headers: headers, extra: extra as Map<String, dynamic>?),
      );
      return _toHttpResponse<T>(response);
    } on DioException catch (e, st) {
      throw _mapDioException(e, st);
    }
  }

  @override
  Future<HttpResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? headers,
    dynamic extra,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParams,
        options: Options(headers: headers, extra: extra as Map<String, dynamic>?),
      );
      return _toHttpResponse<T>(response);
    } on DioException catch (e, st) {
      throw _mapDioException(e, st);
    }
  }

  @override
  Future<HttpResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? headers,
    dynamic extra,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParams,
        options: Options(headers: headers, extra: extra as Map<String, dynamic>?),
      );
      return _toHttpResponse<T>(response);
    } on DioException catch (e, st) {
      throw _mapDioException(e, st);
    }
  }

  HttpResponse<T> _toHttpResponse<T>(Response response) {
    return HttpResponse<T>(
      data: response.data as T?,
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      headers: response.headers.map,
      extra: response.extra,
    );
  }

  HttpNetworkException _mapDioException(DioException e, StackTrace st) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    return HttpNetworkException(
      message: e.message ?? 'Erro inesperado na comunicação com o servidor.',
      statusCode: statusCode,
      data: data,
      type: statusCode == 401 ? HttpErrorType.unauthorized : HttpErrorType.unknown,
      originalError: e,
      stackTrace: st,
    );
  }
}
