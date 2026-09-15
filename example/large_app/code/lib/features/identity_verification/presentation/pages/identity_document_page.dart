import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/navigation/coordinator_provider.dart';
import '../../coordinator/identity_verification_coordinator.dart';
import '../controllers/identity_verification_cubit.dart';
import '../controllers/identity_verification_state.dart';

class IdentityDocumentPage extends StatefulWidget {
  final IdentityVerificationCubit cubit;

  const IdentityDocumentPage({super.key, required this.cubit});

  @override
  State<IdentityDocumentPage> createState() => _IdentityDocumentPageState();
}

class _IdentityDocumentPageState extends State<IdentityDocumentPage> {
  final _docController = TextEditingController(text: 'ID-992-481');

  @override
  void dispose() {
    _docController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coordinator =
        CoordinatorProvider.instance.get<IdentityVerificationCoordinator>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Step 1: Documentation'),
      ),
      body: BlocConsumer<IdentityVerificationCubit, IdentityVerificationState>(
        bloc: widget.cubit,
        listener: (context, state) {
          if (state is IdentityDocumentValidState) {
            // Once document is validated in Cubit, coordinator routes to biometrics
            coordinator?.goToBiometrics();
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Official Document Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Data entered here is handled by IdentityVerificationCubit. '
                  'When the module is unmounted, the Cubit is closed automatically '
                  'via BlocBase.close() and purged from memory.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _docController,
                  decoration: InputDecoration(
                    labelText: 'Document / Identity Number',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.badge_outlined),
                    errorText: state is IdentityErrorState ? state.message : null,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  icon: state is IdentityDocumentSubmittingState
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.arrow_forward),
                  label: const Text('Proceed to Biometrics Sub-Module'),
                  onPressed: state is IdentityDocumentSubmittingState
                      ? null
                      : () {
                          widget.cubit.submitDocument(_docController.text);
                        },
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => coordinator?.goBack(),
                  child: const Text('Back to Module Intro'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
