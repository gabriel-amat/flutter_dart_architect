import 'package:flutter/material.dart';
import '../../features/auth/auth_routes.dart';

/// Centralized router combining all modular feature routes.
abstract final class CustomRouter {
  /// Combined route table aggregating all modular route maps.
  static final Map<String, WidgetBuilder> _routes = {
    ...authRoutes,
    // Add other feature routes here as your app grows:
    // ...meetingRoutes,
    // ...profileRoutes,
  };

  /// Main generator passed to MaterialApp.onGenerateRoute.
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final builder = _routes[settings.name];

    if (builder != null) {
      return MaterialPageRoute(
        builder: builder,
        settings: settings,
      );
    }

    // Fallback for undefined routes
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Página não encontrada')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text('Rota não encontrada: ${settings.name}'),
            ],
          ),
        ),
      ),
      settings: settings,
    );
  }
}
