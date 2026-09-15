import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'native_types.dart';

// Native C function signatures
typedef _NativeAddC = Int32 Function(Int32 a, Int32 b);
typedef _NativeAddDart = int Function(int a, int b);

typedef _NativeHashC = Void Function(
  Pointer<Utf8> input,
  Pointer<Utf8> outputBuffer,
  Int32 maxBufferLen,
);
typedef _NativeHashDart = void Function(
  Pointer<Utf8> input,
  Pointer<Utf8> outputBuffer,
  int maxBufferLen,
);

typedef _NativeGenKeyC = Pointer<KeyPairStruct> Function(Pointer<Utf8> seed);
typedef _NativeGenKeyDart = Pointer<KeyPairStruct> Function(Pointer<Utf8> seed);

typedef _NativeFreeKeyC = Void Function(Pointer<KeyPairStruct> pair);
typedef _NativeFreeKeyDart = void Function(Pointer<KeyPairStruct> pair);

typedef _NativeBenchmarkC = BenchmarkTelemetryStruct Function(Int32 iterations);
typedef _NativeBenchmarkDart = BenchmarkTelemetryStruct Function(int iterations);

/// Low-level C-ABI binding container managing [DynamicLibrary] and function pointers
class NativeCryptoBindings {
  NativeCryptoBindings([DynamicLibrary? library])
      : _dylib = library ?? _loadLibrary() {
    _add = _dylib
        .lookup<NativeFunction<_NativeAddC>>('native_add')
        .asFunction<_NativeAddDart>();

    _hashString = _dylib
        .lookup<NativeFunction<_NativeHashC>>('native_hash_string')
        .asFunction<_NativeHashDart>();

    _generateKeyPair = _dylib
        .lookup<NativeFunction<_NativeGenKeyC>>('native_generate_key_pair')
        .asFunction<_NativeGenKeyDart>();

    _freeKeyPair = _dylib
        .lookup<NativeFunction<_NativeFreeKeyC>>('native_free_key_pair')
        .asFunction<_NativeFreeKeyDart>();

    _runBenchmark = _dylib
        .lookup<NativeFunction<_NativeBenchmarkC>>('native_run_benchmark')
        .asFunction<_NativeBenchmarkDart>();
  }

  final DynamicLibrary _dylib;

  late final _NativeAddDart _add;
  late final _NativeHashDart _hashString;
  late final _NativeGenKeyDart _generateKeyPair;
  late final _NativeFreeKeyDart _freeKeyPair;
  late final _NativeBenchmarkDart _runBenchmark;

  int nativeAdd(int a, int b) => _add(a, b);

  void nativeHashString(Pointer<Utf8> input, Pointer<Utf8> outputBuffer, int maxBufferLen) =>
      _hashString(input, outputBuffer, maxBufferLen);

  Pointer<KeyPairStruct> nativeGenerateKeyPair(Pointer<Utf8> seed) =>
      _generateKeyPair(seed);

  void nativeFreeKeyPair(Pointer<KeyPairStruct> pair) => _freeKeyPair(pair);

  BenchmarkTelemetryStruct nativeRunBenchmark(int iterations) =>
      _runBenchmark(iterations);

  static DynamicLibrary _loadLibrary() {
    if (Platform.isMacOS) {
      // Check local directory first (for tests/cli), then system/bundle
      final localFile = File('libnative_crypto.dylib');
      if (localFile.existsSync()) {
        return DynamicLibrary.open(localFile.absolute.path);
      }
      try {
        return DynamicLibrary.open('libnative_crypto.dylib');
      } catch (_) {
        return DynamicLibrary.process();
      }
    } else if (Platform.isAndroid || Platform.isLinux) {
      final localFile = File('libnative_crypto.so');
      if (localFile.existsSync()) {
        return DynamicLibrary.open(localFile.absolute.path);
      }
      return DynamicLibrary.open('libnative_crypto.so');
    } else if (Platform.isWindows) {
      final localFile = File('native_crypto.dll');
      if (localFile.existsSync()) {
        return DynamicLibrary.open(localFile.absolute.path);
      }
      return DynamicLibrary.open('native_crypto.dll');
    } else if (Platform.isIOS) {
      return DynamicLibrary.process();
    }
    throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
  }
}
