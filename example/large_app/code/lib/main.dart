import 'package:flutter/material.dart';
import 'core/navigation/coordinator_provider.dart';
import 'features/identity_verification/args/identity_verification_args.dart';
import 'features/identity_verification/coordinator/identity_verification_navigator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EnterpriseApp());
}

class EnterpriseApp extends StatelessWidget {
  const EnterpriseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigationGlobalKey,
      title: 'Enterprise Flow Architecture',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A8A)),
      ),
      home: const EnterpriseDashboardPage(),
    );
  }
}

class EnterpriseDashboardPage extends StatelessWidget {
  const EnterpriseDashboardPage({super.key});

  void _openIdentityModule(BuildContext context) async {
    // Launching an enterprise module simply pushes its FeatureNavigator.
    // The FeatureNavigator (a StatefulWidget extending NavigatorBase) manages its lifecycle:
    // 1. initState: Initializes InjectorBase and registers the Coordinator
    // 2. build: Constructs isolated sub-Navigator and handles internal routes
    // 3. dispose: Disposes all singletons and cubits from GC memory automatically.
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const IdentityVerificationNavigator(
          args: IdentityVerificationArgs(
            userId: 'USR-882194',
            protocol: 'PROT-2026-9921',
          ),
        ),
      ),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result == true
                ? 'Flow completed successfully! Entire module and dependencies purged from GC.'
                : 'Flow cancelled or dismissed. Memory reclaimed automatically via dispose().',
          ),
          backgroundColor: result == true ? Colors.green : Colors.blueGrey,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enterprise Architecture (Large Scale)'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.corporate_fare, size: 80, color: Color(0xFF1E3A8A)),
              const SizedBox(height: 24),
              const Text(
                'Enterprise Modular Architecture',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Pattern: Routes + Coordinator + Injector + Navigator (NavigatorBase).\n'
                'Each module manages its private NavigatorKey and Injector, '
                'and its Navigator switch can delegate directly to sub-modules.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.security),
                  label: const Text('Launch Identity Verification (With Sub-Module)'),
                  onPressed: () => _openIdentityModule(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
