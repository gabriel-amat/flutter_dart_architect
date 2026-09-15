import 'dart:ffi';
import 'package:ffi/ffi.dart';

/// Native C struct mapping for `KeyPair`
///
/// typedef struct {
///     char* public_key;
///     char* private_key;
/// } KeyPair;
final class KeyPairStruct extends Struct {
  external Pointer<Utf8> publicKey;

  external Pointer<Utf8> privateKey;
}

/// Native C struct mapping for `BenchmarkTelemetry`
///
/// typedef struct {
///     uint64_t iterations;
///     double elapsed_ms;
///     uint32_t checksum;
/// } BenchmarkTelemetry;
final class BenchmarkTelemetryStruct extends Struct {
  @Uint64()
  external int iterations;

  @Double()
  external double elapsedMs;

  @Uint32()
  external int checksum;
}
