library feature_transfers;

import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class TransfersDashboardPage extends StatelessWidget {
  const TransfersDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transfers (Feature Package)')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.swap_horiz, size: 64, color: DsColors.primary),
              const SizedBox(height: 16),
              const Text('100% isolated transfers feature package.'),
              const SizedBox(height: 24),
              DsPrimaryButton(
                label: 'New Transfer',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
