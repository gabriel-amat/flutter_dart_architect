import 'package:flutter/material.dart';
import 'coordinator_provider.dart';

/// Abstract base class for navigation coordinators in enterprise modular architectures.
///
/// Each module or feature owns its private Coordinator with an isolated [navigationKey].
/// All screen transitions are exposed as typed, semantic methods on this class.
abstract class Coordinator {
  GlobalKey<NavigatorState> get navigationKey;

  /// Finishes the current flow.
  ///
  /// If [result] is provided, pops through the previous coordinator on the stack,
  /// passing the typed result. Otherwise, pops all routes until the root.
  void finishFlow<T extends Object>([T? result]) {
    if (result == null) {
      return navigationKey.currentState!.popUntil((route) => false);
    }
    CoordinatorProvider.instance
        .getPreviousLast()
        ?.navigationKey
        .currentState
        ?.pop(result);
  }
}
