import 'package:flutter/material.dart';
import '../../../core/di/injector_base.dart';
import '../../../core/navigation/navigator_base.dart';
import '../args/biometric_args.dart';
import 'biometric_coordinator.dart';
import 'biometric_injector.dart';
import 'biometric_routes.dart';
import '../presentation/pages/biometric_capture_page.dart';
import '../presentation/pages/biometric_intro_page.dart';

class BiometricNavigator extends StatefulWidget {
  final BiometricArgs args;

  const BiometricNavigator({super.key, required this.args});

  @override
  State<BiometricNavigator> createState() =>
      _BiometricNavigatorState(BiometricInjector(args: args));
}

typedef _NavigatorBaseBiometric =
    NavigatorBase<BiometricNavigator, BiometricCoordinator>;

class _BiometricNavigatorState extends _NavigatorBaseBiometric {
  _BiometricNavigatorState(BiometricInjector injector)
      : super(BiometricCoordinator(), injector);

  @override
  Route<dynamic> onGenerateRoute(
    RouteSettings settings,
    InjectorBase injector,
  ) {
    final route = BiometricRoutes.values.firstWhere(
      (r) => r.path == settings.name,
      orElse: () => BiometricRoutes.base,
    );

    switch (route) {
      case BiometricRoutes.base:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => BiometricIntroPage(cubit: injector.get()),
        );
      case BiometricRoutes.capture:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => BiometricCapturePage(cubit: injector.get()),
        );
    }
  }
}
