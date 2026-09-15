enum HttpErrorType {
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  conflict,
  unprocessableEntity,
  serverError,
  connectionTimeout,
  sendTimeout,
  receiveTimeout,
  badCertificate,
  cancel,
  connectionError,
  unknown,
}

/// Unified network exception thrown by concrete IHttpClient implementations.
class HttpNetworkException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;
  final HttpErrorType type;
  final Object? originalError;
  final StackTrace? stackTrace;

  const HttpNetworkException({
    required this.message,
    this.statusCode,
    this.data,
    this.type = HttpErrorType.unknown,
    this.originalError,
    this.stackTrace,
  });

  bool get isUnauthorized => type == HttpErrorType.unauthorized || statusCode == 401;
  bool get isConnectionError =>
      type == HttpErrorType.connectionError ||
      type == HttpErrorType.connectionTimeout ||
      type == HttpErrorType.receiveTimeout ||
      type == HttpErrorType.sendTimeout;

  @override
  String toString() =>
      'HttpNetworkException(statusCode: $statusCode, type: $type, message: $message)';
}
