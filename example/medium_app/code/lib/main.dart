import 'package:flutter/material.dart';
import 'app.dart';
import 'core/di/app_injector.dart';
import 'core/di/injector_impl.dart';
import 'core/di/service_locator.dart';
import 'core/navigation/navigation_controller.dart';
import 'core/network/dio_http_client.dart';
import 'core/network/http_client.dart';
import 'core/utils/custom_snack.dart';
import 'features/auth/auth_dependencies.dart';

// ============================================================================
// 🚀 BOOTSTRAP & DEPENDENCY INJECTION SETUP
// ============================================================================

/// Configures all application dependencies across Core and Feature modules.
/// This runs BEFORE runApp() to guarantee that every service, controller, and
/// use case is registered and ready for execution.
void setDependencies() {
  // 1. Instantiate the concrete DI container implementation.
  // In your real projects, this could wrap `get_it`, `auto_injector`, or custom containers.
  final AppInjector injector = AppInjectorImpl();

  // --------------------------------------------------------------------------
  // A. Core Infrastructure Singletons
  // --------------------------------------------------------------------------

  // 🧭 NavigationController:
  // Holds GlobalKey<NavigatorState>() to allow contextless navigation:
  //   locator.get<NavigationController>().pushReplacementNamed('/home');
  // Eliminates the anti-pattern of passing BuildContext into Blocs or UseCases.
  injector.registerSingleton<NavigationController>(
    () => NavigationController(),
  );

  // 💬 CustomSnack:
  // Holds GlobalKey<ScaffoldMessengerState>() for contextless snackbar feedback:
  //   locator.get<CustomSnack>().success(text: 'Transferência concluída com sucesso!');
  //   locator.get<CustomSnack>().error(text: 'Sessão expirada.');
  injector.registerSingleton<CustomSnack>(
    () => CustomSnack(),
  );

  // 🌐 Core Network Client:
  // Injects the decoupled IHttpClient interface.
  // Features and DataSources NEVER depend directly on the Dio package.
  injector.registerSingleton<IHttpClient>(
    () => DioHttpClient(),
  );

  // --------------------------------------------------------------------------
  // B. Feature Modules Registration
  // --------------------------------------------------------------------------
  // Each feature is responsible for registering its own DataSources,
  // Repositories, UseCases, and Controllers. This keeps the bootstrap file
  // clean and prevents circular dependencies between modules.
  AuthDependencies.setup(injector);

  // As your application grows, simply plug in new feature modules:
  // ProfileDependencies.setup(injector);
  // TransferDependencies.setup(injector);

  // --------------------------------------------------------------------------
  // C. Commit & Service Locator Initialization
  // --------------------------------------------------------------------------
  // Binds the configured injector to the global `locator` instance.
  locator.setup(injector);
  injector.commit();
}

// ============================================================================
// 🏁 APPLICATION ENTRY POINT
// ============================================================================

void main() {
  // Guarantees Flutter engine bindings are initialized before calling async code or DI
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize all architecture dependencies
  setDependencies();

  // Launch root application widget
  runApp(const App());
}
