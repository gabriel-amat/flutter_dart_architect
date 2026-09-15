import 'package:flutter/material.dart';
import '../../../../core/navigation/coordinator_provider.dart';
import '../../coordinator/identity_verification_coordinator.dart';
import '../controllers/identity_verification_cubit.dart';

class IdentityIntroPage extends StatelessWidget {
  final IdentityVerificationCubit cubit;

  const IdentityIntroPage({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final coordinator =
        CoordinatorProvider.instance.get<IdentityVerificationCoordinator>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Identity Verification'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => coordinator?.finishWithResult(success: false),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.verified_user_outlined, size: 80, color: Color(0xFF1E3A8A)),
            const SizedBox(height: 24),
            Text(
              'User Identification: ${cubit.args.userId}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Service Protocol: ${cubit.args.protocol}',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => coordinator?.goToDocument(),
              child: const Text('Start Document Validation'),
            ),
          ],
        ),
      ),
    );
  }
}
