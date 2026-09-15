import 'package:flutter/services.dart';
import '../core/errors/platform_bridge_exception.dart';
import '../models/device_security_status.dart';
import 'i_security_bridge.dart';

/// Concrete implementation wrapping Flutter's [MethodChannel] and [EventChannel].
///
/// Encapsulates platform communication, type casting, and converts [PlatformException]
/// into strongly typed [PlatformBridgeException].
class SecurityBridgeImpl implements ISecurityBridge {
  static const MethodChannel _defaultMethodChannel =
      MethodChannel('com.architect.enterprise/security');

  static const EventChannel _defaultEventChannel =
      EventChannel('com.architect.enterprise/hardware_events');

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;

  const SecurityBridgeImpl({
    MethodChannel methodChannel = _defaultMethodChannel,
    EventChannel eventChannel = _defaultEventChannel,
  })  : _methodChannel = methodChannel,
        _eventChannel = eventChannel;

  @override
  Future<DeviceSecurityStatus> getSecurityStatus() async {
    try {
      final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>('getSecurityStatus');
      if (result == null) {
        throw const PlatformBridgeException(
          code: 'NULL_RESPONSE',
          message: 'Platform returned null for security status.',
        );
      }
      return DeviceSecurityStatus.fromMap(result);
    } on PlatformException catch (e) {
      throw PlatformBridgeException(
        code: e.code,
        message: e.message ?? 'Failed to retrieve native security status.',
        details: e.details,
      );
    }
  }

  @override
  Future<bool> verifyBiometrics({required String promptReason}) async {
    try {
      final result = await _methodChannel.invokeMethod<bool>(
        'verifyBiometrics',
        {'promptReason': promptReason},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      throw PlatformBridgeException(
        code: e.code,
        message: e.message ?? 'Biometric verification failed on native platform.',
        details: e.details,
      );
    }
  }

  @override
  Stream<String> get hardwareEventStream {
    return _eventChannel
        .receiveBroadcastStream()
        .map((dynamic event) => event.toString())
        .handleError((dynamic error) {
      if (error is PlatformException) {
        throw PlatformBridgeException(
          code: error.code,
          message: error.message ?? 'Error in native hardware event stream.',
          details: error.details,
        );
      }
      throw error;
    });
  }
}
