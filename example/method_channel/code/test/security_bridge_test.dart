import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:method_channel_example/core/errors/platform_bridge_exception.dart';
import 'package:method_channel_example/services/security_bridge_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const methodChannel = MethodChannel('com.architect.enterprise/security');
  late SecurityBridgeImpl bridge;

  setUp(() {
    bridge = const SecurityBridgeImpl(methodChannel: methodChannel);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, null);
  });

  group('SecurityBridgeImpl Unit Tests (Mocking MethodChannel)', () {
    test('getSecurityStatus returns parsed DeviceSecurityStatus on success', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, (MethodCall call) async {
        if (call.method == 'getSecurityStatus') {
          return {
            'isCompromised': false,
            'osVersion': 'Android 14',
            'securityPatchLevel': '2026-03-01',
            'hasSecureHardware': true,
          };
        }
        return null;
      });

      final status = await bridge.getSecurityStatus();

      expect(status.isCompromised, isFalse);
      expect(status.osVersion, 'Android 14');
      expect(status.securityPatchLevel, '2026-03-01');
      expect(status.hasSecureHardware, isTrue);
    });

    test('verifyBiometrics passes arguments and receives true', () async {
      String? capturedPrompt;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, (MethodCall call) async {
        if (call.method == 'verifyBiometrics') {
          capturedPrompt = (call.arguments as Map)['promptReason'] as String?;
          return true;
        }
        return null;
      });

      final result = await bridge.verifyBiometrics(promptReason: 'Authorize Transfer');

      expect(result, isTrue);
      expect(capturedPrompt, 'Authorize Transfer');
    });

    test('translates PlatformException to PlatformBridgeException', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, (MethodCall call) async {
        throw PlatformException(
          code: 'HARDWARE_FAILED',
          message: 'Biometric sensor failure',
        );
      });

      expect(
        () => bridge.verifyBiometrics(promptReason: 'Test'),
        throwsA(isA<PlatformBridgeException>().having(
          (e) => e.code,
          'code',
          'HARDWARE_FAILED',
        )),
      );
    });
  });
}
