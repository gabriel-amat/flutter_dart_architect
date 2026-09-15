sealed class IdentityVerificationState {
  const IdentityVerificationState();
}

class IdentityInitialState extends IdentityVerificationState {
  const IdentityInitialState();
}

class IdentityDocumentSubmittingState extends IdentityVerificationState {
  const IdentityDocumentSubmittingState();
}

class IdentityDocumentValidState extends IdentityVerificationState {
  final String documentNumber;
  const IdentityDocumentValidState({required this.documentNumber});
}

class IdentityErrorState extends IdentityVerificationState {
  final String message;
  const IdentityErrorState({required this.message});
}
