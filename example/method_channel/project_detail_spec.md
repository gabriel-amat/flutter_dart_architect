# 🔌 Method Channel & Native Platform Bridge Specification (`method_channel`)

### Decoupled, Type-Safe & Testable Flutter-to-Native Platform Interoperability
*Maintainer: Gabriel Amat | Target: Dart 3.3+ / Flutter 3.19+*

---

## 🎯 Purpose & Scope

Flutter applications often need to communicate with host operating system APIs (Android SDK, iOS Cocoa Touch) for platform-specific capabilities such as:
- Biometric hardware authentication (Face ID, Touch ID, BiometricPrompt).
- Hardware security indicators (Jailbreak / Root detection, Hardware Keystore, Secure Enclave).
- Native OS sensors, Bluetooth LE peripherals, or background battery events.

A common pitfall is scattering raw `MethodChannel('channel_name').invokeMethod('foo')` calls directly inside UI widgets or state controllers. This causes:
1. **Zero testability**: Native channels crash in unit tests (`MissingPluginException`) unless mocked.
2. **Untyped serialization hazards**: Typo in method names or dictionary keys leads to runtime crashes.
3. **Leaky platform exceptions**: Raw `PlatformException` bleeds into presentation logic.

The **Method Channel** standard provides an enterprise-grade architectural pattern with **clean decoupling, typed domain contracts, and testable mock channels**.

---

## 📁 Architecture & Directory Structure

```
example/method_channel/
 ├─ project_detail_spec.md             # This specification
 └─ code/
     ├─ android/
     │   └─ app/src/main/kotlin/.../
     │       └─ MainActivity.kt        # Kotlin MethodChannel & EventChannel.StreamHandler
     ├─ ios/
     │   └─ Runner/
     │       └─ AppDelegate.swift      # Swift FlutterMethodChannel & FlutterStreamHandler
     ├─ lib/
     │   ├─ core/
     │   │   └─ errors/
     │   │       └─ platform_bridge_exception.dart # Domain-typed exception
     │   ├─ models/
     │   │   └─ device_security_status.dart        # Immutable Dart domain entity
     │   ├─ services/
     │   │   ├─ i_security_bridge.dart             # Abstract interface contract
     │   │   └─ security_bridge_impl.dart          # Concrete MethodChannel + EventChannel
     │   └─ main.dart                              # Diagnostic UI and presentation logic
     └─ test/
         └─ security_bridge_test.dart              # Mocking BinaryMessenger without device
```

---

## ⚡ Core Rules & Best Practices

### 1. Abstract Interface First (`ISecurityBridge`)
Always define an abstract interface separating the Flutter app logic from `dart:services`:

```dart
abstract interface class ISecurityBridge {
  Future<DeviceSecurityStatus> getSecurityStatus();
  Future<bool> verifyBiometrics({required String reason});
  Stream<double> get batteryLevelStream;
}
```

This guarantees:
- Presentation widgets and BLoCs / Cubits depend **only** on `ISecurityBridge`.
- In unit and widget tests, you can trivially provide a mock `ISecurityBridge` without touching native channels.

---

### 2. MethodChannel & EventChannel Separation
- **`MethodChannel`**: Request-response async execution (e.g. `getSecurityStatus`, `authenticate`).
- **`EventChannel`**: Reactive native-to-Flutter streaming (e.g. battery level changes, sensor telemetry, step counting).

```dart
class SecurityBridgeImpl implements ISecurityBridge {
  static const MethodChannel _methodChannel =
      MethodChannel('com.architect.platform/security');
  static const EventChannel _eventChannel =
      EventChannel('com.architect.platform/battery_events');

  @override
  Future<DeviceSecurityStatus> getSecurityStatus() async {
    try {
      final Map<dynamic, dynamic>? result =
          await _methodChannel.invokeMethod<Map<dynamic, dynamic>>('getSecurityStatus');
      
      if (result == null) {
        throw const PlatformBridgeException(
          code: 'NULL_RESPONSE',
          message: 'Received null payload from native host.',
        );
      }

      return DeviceSecurityStatus.fromMap(Map<String, dynamic>.from(result));
    } on PlatformException catch (e) {
      throw PlatformBridgeException(
        code: e.code,
        message: e.message ?? 'Unknown native error',
        details: e.details,
      );
    }
  }

  @override
  Stream<double> get batteryLevelStream => _eventChannel
      .receiveBroadcastStream()
      .map((dynamic event) => (event as num).toDouble())
      .handleError((error) {
        throw PlatformBridgeException(
          code: 'STREAM_ERROR',
          message: error.toString(),
        );
      });
}
```

---

### 3. Native Implementations (Kotlin & Swift)

#### Android (Kotlin)
Handle calls cleanly inside `configureFlutterEngine`:
```kotlin
MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.architect.platform/security")
    .setMethodCallHandler { call, result ->
        when (call.method) {
            "getSecurityStatus" -> {
                val isRooted = checkRoot()
                val hasBiometrics = checkBiometrics()
                result.success(mapOf(
                    "isSecure" to !isRooted,
                    "isRootedOrJailbroken" to isRooted,
                    "hasBiometricsHardware" to hasBiometrics,
                    "securityPatchDate" to "2026-03-01"
                ))
            }
            "authenticateBiometrics" -> {
                val reason = call.argument<String>("reason") ?: "Authentication required"
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }
```

#### iOS (Swift)
```swift
let channel = FlutterMethodChannel(
    name: "com.architect.platform/security",
    binaryMessenger: controller.binaryMessenger
)
channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
    switch call.method {
    case "getSecurityStatus":
        result([
            "isSecure": true,
            "isRootedOrJailbroken": false,
            "hasBiometricsHardware": true,
            "securityPatchDate": "iOS 18.2-2026"
        ])
    case "authenticateBiometrics":
        result(true)
    default:
        result(FlutterMethodNotImplemented)
    }
}
```

---

### 4. Unit Testing Platform Channels in Pure Dart
Do not rely on integration tests running on physical devices to test your bridge parsing and error handling.
Use `TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler`:

```dart
test('getSecurityStatus returns parsed DeviceSecurityStatus on success', () async {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
    if (methodCall.method == 'getSecurityStatus') {
      return {
        'isSecure': true,
        'isRootedOrJailbroken': false,
        'hasBiometricsHardware': true,
        'securityPatchDate': '2026-03-01',
      };
    }
    return null;
  });

  final status = await bridge.getSecurityStatus();
  expect(status.isSecure, isTrue);
  expect(status.isRootedOrJailbroken, isFalse);
});
```

---

## ⚖️ When to Use MethodChannel vs Dart FFI

| Criteria | `MethodChannel` | `Dart FFI` (`dart:ffi`) |
| :--- | :--- | :--- |
| **Target Code** | Java, Kotlin, Objective-C, Swift (OS APIs) | C, C++, Rust, Zig, Go (C-ABI) |
| **Communication** | Asynchronous, IPC/Thread hop, MessageCodec | Synchronous, direct in-process C function call |
| **Performance** | Overhead from thread hop and serialization | Zero-copy, near native CPU speed |
| **Typical Use Cases** | Camera, Biometrics, Sensors, Apple/Google Pay | Cryptography, Image/Audio processing, SQLite/RocksDB, Game engines |
