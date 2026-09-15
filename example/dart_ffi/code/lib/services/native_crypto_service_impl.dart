import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../ffi/native_bindings.dart';
import '../ffi/native_types.dart';
import '../models/crypto_models.dart';
import 'i_native_crypto_service.dart';

/// Concrete implementation of [INativeCryptoService] leveraging Dart FFI,
/// Arenas for scoped automatic memory deallocation, and safe struct conversion.
class NativeCryptoServiceImpl implements INativeCryptoService {
  NativeCryptoServiceImpl({NativeCryptoBindings? bindings})
      : _bindings = bindings ?? NativeCryptoBindings();

  final NativeCryptoBindings _bindings;

  @override
  int add(int a, int b) {
    return _bindings.nativeAdd(a, b);
  }

  @override
  String hashString(String input) {
    // Arena allocator automatically frees all pointers allocated within this scope
    // upon scope exit, preventing native memory leaks without manual free() calls.
    return using((Arena arena) {
      final Pointer<Utf8> inputPtr = input.toNativeUtf8(allocator: arena);
      const int bufferLen = 128;
      final Pointer<Utf8> outputPtr =
          arena<Uint8>(bufferLen).cast<Utf8>();

      _bindings.nativeHashString(inputPtr, outputPtr, bufferLen);

      return outputPtr.toDartString();
    });
  }

  @override
  CryptoKeyPair generateKeyPair(String seed) {
    return using((Arena arena) {
      final Pointer<Utf8> seedPtr = seed.toNativeUtf8(allocator: arena);

      // C function allocates KeyPair struct and internal strings on native heap
      final Pointer<KeyPairStruct> pairPtr =
          _bindings.nativeGenerateKeyPair(seedPtr);

      if (pairPtr == nullptr) {
        throw StateError('Native C runtime failed to allocate KeyPair struct.');
      }

      try {
        // Read native struct fields and convert UTF-8 C strings to immutable Dart Strings
        final String pubKey = pairPtr.ref.publicKey.toDartString();
        final String privKey = pairPtr.ref.privateKey.toDartString();

        return CryptoKeyPair(
          publicKey: pubKey,
          privateKey: privKey,
        );
      } finally {
        // Essential: Free native heap memory allocated by C to prevent memory leaks
        _bindings.nativeFreeKeyPair(pairPtr);
      }
    });
  }

  @override
  BenchmarkResult runBenchmark({int iterations = 1000000}) {
    // BenchmarkTelemetryStruct is returned by value directly across the C-ABI
    final BenchmarkTelemetryStruct telemetry =
        _bindings.nativeRunBenchmark(iterations);

    return BenchmarkResult(
      iterations: telemetry.iterations,
      elapsedMs: telemetry.elapsedMs,
      checksum: telemetry.checksum,
    );
  }
}
