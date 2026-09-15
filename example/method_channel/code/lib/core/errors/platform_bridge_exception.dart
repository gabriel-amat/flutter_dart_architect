class PlatformBridgeException implements Exception {
  final String code;
  final String message;
  final dynamic details;

  const PlatformBridgeException({
    required this.code,
    required this.message,
    this.details,
  });

  @override
  String toString() => 'PlatformBridgeException($code): $message';
}
