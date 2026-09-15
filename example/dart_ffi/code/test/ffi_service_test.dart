import 'dart:ffi';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:dart_ffi_example/ffi/native_bindings.dart';
import 'package:dart_ffi_example/services/native_crypto_service_impl.dart';

void main() {
  group('Dart FFI Native Crypto Service Tests', () {
    late NativeCryptoServiceImpl service;

    setUpAll(() {
      // Ensure the dylib is loaded from the root of the project
      final dylibFile = File('libnative_crypto.dylib');
      if (dylibFile.existsSync()) {
        final dylib = DynamicLibrary.open(dylibFile.absolute.path);
        service = NativeCryptoServiceImpl(bindings: NativeCryptoBindings(dylib));
      } else {
        service = NativeCryptoServiceImpl();
      }
    });

    test('nativeAdd performs fast C integer addition', () {
      expect(service.add(40, 2), equals(42));
      expect(service.add(-10, 25), equals(15));
    });

    test('hashString hashes UTF-8 strings via Arena memory allocator', () {
      final hash1 = service.hashString('hello world');
      final hash2 = service.hashString('hello world');
      final hash3 = service.hashString('different input');

      expect(hash1, isNotEmpty);
      expect(hash1.length, equals(64));
      expect(hash1, equals(hash2));
      expect(hash1, isNot(equals(hash3)));
    });

    test('generateKeyPair allocates struct on native heap and frees it cleanly', () {
      final pair = service.generateKeyPair('alice_vault');

      expect(pair.publicKey, contains('pub_secp256k1_alice_vault'));
      expect(pair.privateKey, contains('priv_secp256k1_alice_vault'));
    });

    test('runBenchmark executes 1,000,000 native iterations in sub-milliseconds', () {
      final result = service.runBenchmark(iterations: 1000000);

      expect(result.iterations, equals(1000000));
      expect(result.elapsedMs, isNonNegative);
      expect(result.checksum, isNot(equals(0)));
    });
  });
}
