import '../models/crypto_models.dart';

/// Abstract service contract isolating presentation logic from `dart:ffi` pointers
abstract interface class INativeCryptoService {
  /// Performs low-latency integer arithmetic via C-ABI
  int add(int a, int b);

  /// Computes a native cryptographic hash of [input] with zero-copy memory allocation
  String hashString(String input);

  /// Generates a key pair from [seed] using native heap allocation and clean memory disposal
  CryptoKeyPair generateKeyPair(String seed);

  /// Runs an in-process native computation benchmark over [iterations]
  BenchmarkResult runBenchmark({int iterations = 1000000});
}
