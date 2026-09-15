import 'package:flutter/material.dart';

void main() {
  runApp(const DefaultModuleApp());
}

/// Dedicated entrypoint for the Checkout feature inside the native host app.
/// Triggered via FlutterEngineGroup using entrypoint: 'checkoutEntryPoint'
@pragma('vm:entry-point')
void checkoutEntryPoint() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CheckoutModuleApp());
}

class DefaultModuleApp extends StatelessWidget {
  const DefaultModuleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Flutter Module Default Entrypoint')),
      ),
    );
  }
}

class CheckoutModuleApp extends StatelessWidget {
  const CheckoutModuleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Checkout Module',
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Checkout (Embedded Flutter)'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Calls Pigeon bridge to close the native container
            },
          ),
        ),
        body: const Center(
          child: Text('This screen was rendered by the Flutter module via FlutterEngineGroup.'),
        ),
      ),
    );
  }
}
