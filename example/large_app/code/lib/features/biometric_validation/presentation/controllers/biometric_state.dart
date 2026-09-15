sealed class BiometricState {
  const BiometricState();
}

class BiometricInitialState extends BiometricState {
  const BiometricInitialState();
}

class BiometricCapturingState extends BiometricState {
  const BiometricCapturingState();
}

class BiometricSuccessState extends BiometricState {
  const BiometricSuccessState();
}

class BiometricFailureState extends BiometricState {
  final String error;
  const BiometricFailureState({required this.error});
}
