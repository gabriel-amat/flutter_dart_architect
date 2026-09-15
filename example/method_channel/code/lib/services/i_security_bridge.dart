import '../models/device_security_status.dart';

/// Abstract contract for native security and hardware inspection.
///
/// Decouples Flutter domain and UI from raw [MethodChannel] and [EventChannel] invocations.
abstract interface class ISecurityBridge {
  /// Queries native OS security posture (root/jailbreak detection, hardware keystore).
  Future<DeviceSecurityStatus> getSecurityStatus();

  /// Requests hardware-backed biometric authentication from native OS.
  Future<bool> verifyBiometrics({required String promptReason});

  /// Real-time stream of hardware events (e.g. charging state, tampering alerts) emitted by native OS.
  Stream<String> get hardwareEventStream;
}
