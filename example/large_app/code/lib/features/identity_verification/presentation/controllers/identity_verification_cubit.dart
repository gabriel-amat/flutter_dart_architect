import 'package:flutter_bloc/flutter_bloc.dart';
import '../../args/identity_verification_args.dart';
import 'identity_verification_state.dart';

class IdentityVerificationCubit extends Cubit<IdentityVerificationState> {
  final IdentityVerificationArgs args;

  IdentityVerificationCubit({required this.args})
      : super(const IdentityInitialState());

  Future<void> submitDocument(String documentNumber) async {
    if (documentNumber.trim().isEmpty) {
      emit(const IdentityErrorState(message: 'Document number cannot be empty.'));
      return;
    }

    emit(const IdentityDocumentSubmittingState());
    // Simulate domain verification
    await Future<void>.delayed(const Duration(milliseconds: 50));
    emit(IdentityDocumentValidState(documentNumber: documentNumber));
  }

  void reset() {
    emit(const IdentityInitialState());
  }
}
