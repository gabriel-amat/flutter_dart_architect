import 'package:flutter/material.dart';
import 'coordinator.dart';

final GlobalKey<NavigatorState> navigationGlobalKey = GlobalKey<NavigatorState>();

/// Global registry and navigation stack manager for active [Coordinator] instances.
///
/// Tracks active coordinators, enabling safe cross-flow navigation, stack unwinding,
/// and instance retrieval across the widget lifecycle.
class CoordinatorProvider {
  CoordinatorProvider._();

  static final CoordinatorProvider instance = CoordinatorProvider._();
  final Map<Type, Coordinator> _coordinators = {};

  T add<T extends Coordinator>(T coordinator) {
    if (_coordinators.containsKey(T)) {
      return _coordinators[T] as T;
    }
    _coordinators[T] = coordinator;
    return coordinator;
  }

  void removeCoordinator(Coordinator coordinator) {
    _coordinators.remove(coordinator.runtimeType);
  }

  void remove<T extends Coordinator>() {
    _coordinators.remove(T);
  }

  BuildContext? getContext<T extends Coordinator>() =>
      _coordinators[T]?.navigationKey.currentContext;

  Coordinator? getLast() {
    if (_coordinators.isNotEmpty) {
      return _coordinators.values.last;
    }
    return null;
  }

  Coordinator? getPreviousLast() {
    if (_coordinators.values.length >= 2) {
      return _coordinators.values.elementAt(_coordinators.values.length - 2);
    }
    return null;
  }

  void pop() {
    navigationGlobalKey.currentState?.pop();
  }

  T? get<T extends Coordinator>() {
    for (final coordinator in _coordinators.values) {
      if (coordinator is T) return coordinator;
    }
    return null;
  }
}
