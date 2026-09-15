import 'package:flutter/material.dart';
import '../../../../core/navigation/coordinator_provider.dart';
import '../../coordinator/biometric_coordinator.dart';
import '../controllers/biometric_cubit.dart';

class BiometricIntroPage extends StatelessWidget {
  final BiometricCubit cubit;

  const BiometricIntroPage({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final coordinator = CoordinatorProvider.instance.get<BiometricCoordinator>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sub-Module: Facial Biometrics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => coordinator?.cancel(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.face_retouching_natural, size: 80, color: Colors.blueAccent),
            const SizedBox(height: 24),
            Text(
              'Biometrics Verification (Protocol: ${cubit.args.protocol})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'This is an autonomous sub-module. The parent Navigator switch returned '
              'BiometricNavigator, which initialized its own Injector, its BiometricCubit, '
              'and its private NavigatorKey.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Proceed to Face Capture'),
              onPressed: () => coordinator?.goToCapture(),
            ),
          ],
        ),
      ),
    );
  }
}
