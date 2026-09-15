import 'package:flutter/material.dart';
import '../di/injector_base.dart';
import 'coordinator.dart';
import 'coordinator_provider.dart';

/// Abstract base class for the State of an isolated module's Navigator.
///
/// Implements the enterprise pattern connecting the native Flutter Widget lifecycle:
/// 1. [initState]: Initializes module dependencies via [injector.initialize()] and registers
///    the Coordinator in [CoordinatorProvider].
/// 2. [dispose]: Reclaims all instances and memory via [injector.removeAll()] and removes
///    the Coordinator from the active registry.
/// 3. [build]: Constructs a nested [Navigator] backed by the coordinator's private [navigationKey]
///    and handles sub-routes via [onGenerateRoute].
abstract class NavigatorBase<T extends StatefulWidget, V extends Coordinator>
    extends State<T> {
  NavigatorBase(this.coordinator, this.injector);

  final Coordinator coordinator;
  final InjectorBase injector;

  List<String> baseRoutes = ['/'];

  @override
  void initState() {
    super.initState();
    injector.initialize();
    CoordinatorProvider.instance.add<V>(coordinator as V);
  }

  @override
  void dispose() {
    injector.removeAll();
    CoordinatorProvider.instance.remove<V>();
    super.dispose();
  }

  GlobalKey<NavigatorState> get _navigationKey => coordinator.navigationKey;

  /// Required handler where subclasses implement the `switch (route)`
  /// to map [MaterialPageRoute] for screens or another nested [FeatureNavigator].
  Route<dynamic>? onGenerateRoute(
    RouteSettings settings,
    InjectorBase injector,
  );

  @override
  Widget build(BuildContext context) {
    return NavigatorPopHandler(
      onPopWithResult: (_) => _navigationKey.currentState?.maybePop(),
      child: Navigator(
        key: _navigationKey,
        onGenerateRoute: (settings) => onGenerateRoute(settings, injector),
        observers: [
          _PopObserver(
            coordinator: coordinator,
            baseRoutes: baseRoutes,
            pop: Navigator.of(context).pop,
          ),
        ],
      ),
    );
  }
}

class _PopObserver extends RouteObserver<ModalRoute<dynamic>> {
  _PopObserver({
    required this.coordinator,
    required this.baseRoutes,
    required this.pop,
  });

  final List<String> baseRoutes;
  final Coordinator coordinator;
  final VoidCallback pop;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (baseRoutes.contains(route.settings.name) || previousRoute == null) {
      pop();
      CoordinatorProvider.instance.removeCoordinator(coordinator);
    }
    super.didPop(route, previousRoute);
  }
}
