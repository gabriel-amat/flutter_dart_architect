import 'package:flutter/material.dart';

/// Contextless navigation controller managing the global NavigatorState.
class NavigationController {
  final navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState? get state => navigatorKey.currentState;

  Future<T?>? pushNamed<T extends Object?>(String routeName, {Object? arguments}) {
    return state?.pushNamed<T>(routeName, arguments: arguments);
  }

  Future<T?>? pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) {
    return state?.pushReplacementNamed<T, TO>(
      routeName,
      result: result,
      arguments: arguments,
    );
  }

  Future<T?>? pushNamedAndRemoveUntil<T extends Object?>(
    String newRouteName,
    bool Function(Route<dynamic>) predicate, {
    Object? arguments,
  }) {
    return state?.pushNamedAndRemoveUntil<T>(
      newRouteName,
      predicate,
      arguments: arguments,
    );
  }

  void pop<T extends Object?>([T? result]) {
    state?.pop<T>(result);
  }
}
