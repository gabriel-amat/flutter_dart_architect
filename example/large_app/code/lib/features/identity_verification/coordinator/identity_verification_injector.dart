import '../../../core/di/injector_base.dart';
import '../args/identity_verification_args.dart';
import '../presentation/controllers/identity_verification_cubit.dart';

class IdentityVerificationInjector extends InjectorBase {
  final _injector = ModuleInjector();
  final IdentityVerificationArgs args;

  IdentityVerificationInjector({required this.args});

  @override
  T get<T>() => _injector.get<T>();

  @override
  void removeAll() => _injector.removeAll();

  @override
  void initialize() {
    _injector.addLazySingleton<IdentityVerificationArgs>(() => args);
    _injector.addLazySingleton<IdentityVerificationCubit>(
      () => IdentityVerificationCubit(args: _injector.get<IdentityVerificationArgs>()),
    );
  }
}
