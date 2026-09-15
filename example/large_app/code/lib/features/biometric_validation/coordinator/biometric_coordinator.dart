import 'package:flutter/material.dart';
import '../../../core/navigation/coordinator.dart';
import 'biometric_routes.dart';

class BiometricCoordinator extends Coordinator {
  final _navigationKey = GlobalKey<NavigatorState>();

  @override
  GlobalKey<NavigatorState> get navigationKey => _navigationKey;

  Future<void> goToCapture() async {
    await _navigationKey.currentState?.pushNamed<void>(BiometricRoutes.capture.path);
  }

  Future<void> finishWithSuccess() async {
    finishFlow<bool>(true);
  }

  Future<void> cancel() async {
    finishFlow<bool>(false);
  }
}
