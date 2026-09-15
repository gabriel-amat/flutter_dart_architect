import 'package:flutter/material.dart';
import 'core/di/service_locator.dart';
import 'core/navigation/app_pages.dart';
import 'core/navigation/custom_router.dart';
import 'core/navigation/navigation_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/custom_snack.dart';

/// Root application widget.
/// Connects contextless navigation, global snackbars, modular routing, and theming.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Dart Architect Example',
      debugShowCheckedModeBanner: false,

      // 1. Contextless Navigation: Enables locator.get<NavigationController>().pushNamed(...)
      navigatorKey: locator.get<NavigationController>().navigatorKey,

      // 2. Contextless Feedback: Enables locator.get<CustomSnack>().success(...)
      scaffoldMessengerKey: locator.get<CustomSnack>().snackbarKey,

      // 3. Modular Routing: Merges routes from all independent feature modules
      onGenerateRoute: CustomRouter.generateRoute,
      initialRoute: AppPages.login,

      // 4. Centralized Theming
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
    );
  }
}
