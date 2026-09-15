import 'package:flutter/material.dart';
import '../../../core/di/injector_base.dart';
import '../../../core/navigation/navigator_base.dart';
import '../../biometric_validation/args/biometric_args.dart';
import '../../biometric_validation/coordinator/biometric_navigator.dart';
import '../args/identity_verification_args.dart';
import 'identity_verification_coordinator.dart';
import 'identity_verification_injector.dart';
import 'identity_verification_routes.dart';
import '../presentation/pages/identity_document_page.dart';
import '../presentation/pages/identity_intro_page.dart';

/// Primary Navigator widget for the Identity Verification module.
///
/// Manages automatic lifecycle and teardown:
/// - [initState]: Initializes [IdentityVerificationInjector] and registers [IdentityVerificationCoordinator].
/// - [dispose]: Reclaims all module singletons and automatically closes Cubits via [BlocBase.close()].
class IdentityVerificationNavigator extends StatefulWidget {
  final IdentityVerificationArgs args;

  const IdentityVerificationNavigator({super.key, required this.args});

  @override
  State<IdentityVerificationNavigator> createState() =>
      _IdentityVerificationNavigatorState(
        IdentityVerificationInjector(args: args),
      );
}

typedef _NavigatorBaseIdentity =
    NavigatorBase<IdentityVerificationNavigator, IdentityVerificationCoordinator>;

class _IdentityVerificationNavigatorState extends _NavigatorBaseIdentity {
  _IdentityVerificationNavigatorState(IdentityVerificationInjector injector)
      : super(IdentityVerificationCoordinator(), injector);

  @override
  Route<dynamic> onGenerateRoute(
    RouteSettings settings,
    InjectorBase injector,
  ) {
    if (settings.name == '/') {
      settings = RouteSettings(name: '/', arguments: widget.args);
    }

    final route = IdentityVerificationRoutes.values.firstWhere(
      (r) => r.path == settings.name,
      orElse: () => IdentityVerificationRoutes.base,
    );

    switch (route) {
      case IdentityVerificationRoutes.base:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => IdentityIntroPage(cubit: injector.get()),
        );

      case IdentityVerificationRoutes.document:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => IdentityDocumentPage(cubit: injector.get()),
        );

      case IdentityVerificationRoutes.biometrics:
        // SUB-MODULE INVOCATION:
        // When the coordinator triggers `goToBiometrics()`, this switch directly returns
        // [BiometricNavigator]. It initializes its own sub-Navigator and lands on BiometricRoutes.base ('/').
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => BiometricNavigator(
            args: BiometricArgs(protocol: widget.args.protocol),
          ),
        );
    }
  }
}
