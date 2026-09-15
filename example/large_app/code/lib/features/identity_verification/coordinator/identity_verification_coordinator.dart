import 'package:flutter/material.dart';
import '../../../core/navigation/coordinator.dart';
import 'identity_verification_routes.dart';

class IdentityVerificationCoordinator extends Coordinator {
  final _navigationKey = GlobalKey<NavigatorState>();

  @override
  GlobalKey<NavigatorState> get navigationKey => _navigationKey;

  Future<void> goToDocument() async {
    await _navigationKey.currentState?.pushNamed<void>(
      IdentityVerificationRoutes.document.path,
    );
  }

  /// Triggers navigation to the biometrics route.
  ///
  /// The [IdentityVerificationNavigator] handles this in its `switch (route)`
  /// and returns [BiometricNavigator] (an autonomous sub-module).
  Future<void> goToBiometrics() async {
    await _navigationKey.currentState?.pushNamed<void>(
      IdentityVerificationRoutes.biometrics.path,
    );
  }

  Future<void> goToStart() async {
    _navigationKey.currentState?.popUntil((route) => route.isFirst);
  }

  Future<void> goBack() async {
    _navigationKey.currentState?.pop();
  }

  Future<void> finishWithResult({required bool success}) async {
    finishFlow<bool>(success);
  }
}
