import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/navigation/coordinator_provider.dart';
import '../../coordinator/biometric_coordinator.dart';
import '../controllers/biometric_cubit.dart';
import '../controllers/biometric_state.dart';

class BiometricCapturePage extends StatelessWidget {
  final BiometricCubit cubit;

  const BiometricCapturePage({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final coordinator = CoordinatorProvider.instance.get<BiometricCoordinator>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Facial Capture'),
      ),
      body: BlocConsumer<BiometricCubit, BiometricState>(
        bloc: cubit,
        listener: (context, state) {
          if (state is BiometricSuccessState) {
            // Once face is successfully validated, coordinator finishes the flow
            coordinator?.finishWithSuccess();
          }
        },
        builder: (context, state) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: state is BiometricSuccessState
                            ? Colors.green
                            : state is BiometricCapturingState
                                ? Colors.orange
                                : Colors.blue,
                        width: 4,
                      ),
                    ),
                    child: Icon(
                      state is BiometricSuccessState
                          ? Icons.check
                          : state is BiometricCapturingState
                              ? Icons.hourglass_top
                              : Icons.face,
                      size: 80,
                      color: state is BiometricSuccessState ? Colors.green : Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    state is BiometricSuccessState
                        ? 'Face Successfully Validated!'
                        : state is BiometricCapturingState
                            ? 'Analyzing Biometrics...'
                            : 'Position Your Face in Frame',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Managed by BiometricCubit with direct state emission. Calling cubit.captureFace() '
                    'emits Capturing then Success. On success, the coordinator pops back to the parent '
                    'module and BiometricCubit is closed automatically.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: state is BiometricCapturingState
                        ? null
                        : () {
                            cubit.captureFace();
                          },
                    child: Text(
                      state is BiometricCapturingState
                          ? 'Capturing...'
                          : 'Capture & Validate Face',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
