import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/core/bridge/pigeon_bridge.g.dart',
  swiftOut: 'ios_host_example/PigeonBridge.g.swift',
  kotlinOut: 'android_host_example/PigeonBridge.g.kt',
  kotlinOptions: KotlinOptions(package: 'com.example.enterprise.bridge'),
))

/// User session data passed from the native host into Flutter
class NativeSessionData {
  final String accessToken;
  final String userId;
  final String environment;

  NativeSessionData({
    required this.accessToken,
    required this.userId,
    required this.environment,
  });
}

/// Host API: Invoked by Flutter to request data or trigger native actions
@HostApi()
abstract class NativeHostApi {
  NativeSessionData getSessionData();
  void onSessionExpired();
  void closeFlutterScreen();
}

/// Flutter API: Invoked by Native to send real-time events into Flutter
@FlutterApi()
abstract class FlutterConsumerApi {
  void onTokenRefreshed(String newAccessToken);
}
