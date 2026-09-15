import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dart_ffi_example/main.dart';
import 'package:dart_ffi_example/models/crypto_models.dart';
import 'package:dart_ffi_example/services/i_native_crypto_service.dart';

class MockNativeCryptoService implements INativeCryptoService {
  @override
  int add(int a, int b) => a + b;

  @override
  String hashString(String input) => 'mock_sha256_hash_value_1234567890';

  @override
  CryptoKeyPair generateKeyPair(String seed) => const CryptoKeyPair(
        publicKey: 'mock_pub_key',
        privateKey: 'mock_priv_key',
      );

  @override
  BenchmarkResult runBenchmark({int iterations = 1000000}) =>
      const BenchmarkResult(
        iterations: 1000000,
        elapsedMs: 1.25,
        checksum: 987654321,
      );
}

void main() {
  testWidgets('FfiBenchmarkPage renders and executes interactions cleanly',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final mockService = MockNativeCryptoService();

    await tester.pumpWidget(
      MaterialApp(
        home: FfiBenchmarkPage(cryptoService: mockService),
      ),
    );

    expect(find.text('Dart FFI High Performance Engine'), findsOneWidget);
    expect(find.text('Run 5M Native Iterations'), findsOneWidget);

    // Tap Hash
    await tester.tap(find.text('Hash via C Pointer with Arena'));
    await tester.pump();
    expect(find.text('mock_sha256_hash_value_1234567890'), findsOneWidget);

    // Tap KeyPair
    final genBtn = find.text('Generate C Heap Struct & Free');
    await tester.tap(genBtn);
    await tester.pump();
    expect(find.text('mock_pub_key'), findsOneWidget);
    expect(find.text('mock_priv_key'), findsOneWidget);
  });
}
