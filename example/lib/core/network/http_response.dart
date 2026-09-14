/// Generic decoupled HTTP response wrapper.
class HttpResponse<T> {
  final T? data;
  final int? statusCode;
  final String? statusMessage;
  final Map<String, List<String>>? headers;
  final Map<String, dynamic>? extra;

  const HttpResponse({
    this.data,
    this.statusCode,
    this.statusMessage,
    this.headers,
    this.extra,
  });

  bool get isSuccess =>
      statusCode != null && statusCode! >= 200 && statusCode! < 300;
}
