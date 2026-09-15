import 'package:flutter/material.dart';
import 'package:feature_auth/feature_auth.dart';
import 'package:feature_transfers/feature_transfers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CustomerAppShell());
}

class CustomerAppShell extends StatelessWidget {
  const CustomerAppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Customer App (Melos Shell)',
      theme: ThemeData(useMaterial3: true),
      home: AuthLoginPage(
        onLoginSuccess: () {
          // Cross-package navigation handled by the shell app
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TransfersDashboardPage()),
          );
        },
      ),
    );
  }
}
