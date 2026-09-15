import 'package:flutter_bloc/flutter_bloc.dart';
import '../../args/biometric_args.dart';
import 'biometric_state.dart';

class BiometricCubit extends Cubit<BiometricState> {
  final BiometricArgs args;

  BiometricCubit({required this.args}) : super(const BiometricInitialState());

  Future<void> captureFace() async {
    emit(const BiometricCapturingState());
    // Simulate camera capture & biometric verification
    await Future<void>.delayed(const Duration(milliseconds: 50));
    emit(const BiometricSuccessState());
  }

  void reset() {
    emit(const BiometricInitialState());
  }
}
