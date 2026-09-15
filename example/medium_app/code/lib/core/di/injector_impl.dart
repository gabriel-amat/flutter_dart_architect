import 'app_injector.dart';

/// Lightweight in-memory implementation of AppInjector.
/// In production, this can wrap get_it, auto_injector, or any DI container.
class AppInjectorImpl implements AppInjector {
  final Map<Type, Object Function()> _factories = {};
  final Map<Type, Object> _singletons = {};

  @override
  void registerSingleton<T extends Object>(T Function() factory) {
    _singletons[T] = factory();
  }

  @override
  void registerLazySingleton<T extends Object>(T Function() factory) {
    _factories[T] = () {
      if (!_singletons.containsKey(T)) {
        _singletons[T] = factory();
      }
      return _singletons[T]!;
    };
  }

  @override
  void registerFactory<T extends Object>(T Function() factory) {
    _factories[T] = factory;
  }

  @override
  T get<T extends Object>() {
    if (_singletons.containsKey(T)) {
      return _singletons[T] as T;
    }
    if (_factories.containsKey(T)) {
      return _factories[T]!() as T;
    }
    throw StateError('Dependency [$T] is not registered in AppInjector.');
  }

  @override
  void reset() {
    _singletons.clear();
    _factories.clear();
  }

  @override
  void commit() {
    // No-op for simple in-memory container, but useful for containers requiring build/commit.
  }
}
