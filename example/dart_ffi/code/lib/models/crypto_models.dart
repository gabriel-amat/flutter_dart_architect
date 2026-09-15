/// Domain entity representing a generated cryptographic key pair
final class CryptoKeyPair {
  const CryptoKeyPair({
    required this.publicKey,
    required this.privateKey,
  });

  final String publicKey;
  final String privateKey;

  @override
  String toString() => 'CryptoKeyPair(pub: $publicKey, priv: $privateKey)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CryptoKeyPair &&
          runtimeType == other.runtimeType &&
          publicKey == other.publicKey &&
          privateKey == other.privateKey;

  @override
  int get hashCode => Object.hash(publicKey, privateKey);
}

/// Domain entity representing native C computational benchmark telemetry
final class BenchmarkResult {
  const BenchmarkResult({
    required this.iterations,
    required this.elapsedMs,
    required this.checksum,
  });

  final int iterations;
  final double elapsedMs;
  final int checksum;

  @override
  String toString() =>
      'BenchmarkResult(iterations: $iterations, elapsed: ${elapsedMs.toStringAsFixed(3)}ms, checksum: $checksum)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BenchmarkResult &&
          runtimeType == other.runtimeType &&
          iterations == other.iterations &&
          elapsedMs == other.elapsedMs &&
          checksum == other.checksum;

  @override
  int get hashCode => Object.hash(iterations, elapsedMs, checksum);
}
