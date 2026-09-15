import '../../../core/di/injector_base.dart';
import '../args/biometric_args.dart';
import '../presentation/controllers/biometric_cubit.dart';

class BiometricInjector extends InjectorBase {
  final _injector = ModuleInjector();
  final BiometricArgs args;

  BiometricInjector({required this.args});

  @override
  T get<T>() => _injector.get<T>();

  @override
  void removeAll() => _injector.removeAll();

  @override
  void initialize() {
    _injector.addLazySingleton<BiometricArgs>(() => args);
    _injector.addLazySingleton<BiometricCubit>(
      () => BiometricCubit(args: _injector.get<BiometricArgs>()),
    );
  }
}
