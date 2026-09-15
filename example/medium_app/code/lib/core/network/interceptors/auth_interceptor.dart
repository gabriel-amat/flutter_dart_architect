import 'dart:async';
import 'package:dio/dio.dart';

/// Production-ready AuthInterceptor preventing 401 infinite refresh recursion loops.
/// Uses an isolated `cleanDio` instance (free of interceptors) and a Completer concurrency lock.
class AuthInterceptor extends Interceptor {
  final Dio Function() _getCleanDio;
  final FutureOr<String?> Function() _getToken;
  final FutureOr<String?> Function() _getRefreshToken;
  final FutureOr<void> Function(String? token, String? refreshToken) _onSaveTokens;
  final FutureOr<void> Function() _onClearTokens;
  final void Function()? _onTokenExpired;

  Completer<bool>? _refreshCompleter;

  AuthInterceptor({
    required Dio Function() getCleanDio,
    required FutureOr<String?> Function() getToken,
    required FutureOr<String?> Function() getRefreshToken,
    required FutureOr<void> Function(String? token, String? refreshToken) onSaveTokens,
    required FutureOr<void> Function() onClearTokens,
    void Function()? onTokenExpired,
  })  : _getCleanDio = getCleanDio,
        _getToken = getToken,
        _getRefreshToken = getRefreshToken,
        _onSaveTokens = onSaveTokens,
        _onClearTokens = onClearTokens,
        _onTokenExpired = onTokenExpired;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final noAuth = options.extra['noAuth'] == true;
    final token = await _getToken();

    if (!noAuth && token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    final is401 = response?.statusCode == 401;
    final isRetry = err.requestOptions.extra['_isRetry'] == true;
    final isAuthPath = err.requestOptions.path.contains('/auth/login') ||
        err.requestOptions.path.contains('/auth/register') ||
        err.requestOptions.path.contains('/auth/refresh');

    // Abort refresh attempt if not 401, if already retried once, or if on auth endpoints
    if (!is401 || isRetry || isAuthPath) {
      return super.onError(err, handler);
    }

    final refreshToken = await _getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _handleSessionExpired();
      return super.onError(err, handler);
    }

    try {
      final success = await _performRefreshToken(refreshToken);
      if (!success) {
        await _handleSessionExpired();
        return super.onError(err, handler);
      }

      // Token successfully refreshed. Update request header and re-fetch with cleanDio.
      final newToken = await _getToken();
      final options = err.requestOptions;
      if (newToken != null && newToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $newToken';
      }
      options.extra['_isRetry'] = true;

      final cleanDio = _getCleanDio();
      final retriedResponse = await cleanDio.fetch(options);

      return handler.resolve(retriedResponse);
    } catch (e) {
      await _handleSessionExpired();
      return super.onError(err, handler);
    }
  }

  Future<bool> _performRefreshToken(String refreshToken) async {
    // If a refresh is already in flight, wait for it instead of spawning concurrent refreshes
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<bool>();

    try {
      final cleanDio = _getCleanDio();

      final response = await cleanDio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: {'Authorization': 'Bearer $refreshToken'},
        ),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        final newAccessToken = data['token'] as String? ?? data['access_token'] as String?;
        final newRefreshToken = data['refresh_token'] as String? ?? refreshToken;

        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          await _onSaveTokens(newAccessToken, newRefreshToken);
          _refreshCompleter?.complete(true);
          return true;
        }
      }

      _refreshCompleter?.complete(false);
      return false;
    } catch (_) {
      _refreshCompleter?.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }

  Future<void> _handleSessionExpired() async {
    await _onClearTokens();
    _onTokenExpired?.call();
  }
}
