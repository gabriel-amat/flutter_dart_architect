import 'package:flutter_bloc/flutter_bloc.dart';

/// Abstract contract for isolated module dependency injection.
///
/// Each module encapsulates its dependencies (DataSources, Repositories, UseCases, Blocs)
/// and guarantees memory reclamation in [removeAll()] when the Navigator is disposed.
abstract class InjectorBase {
  T get<T>();
  void initialize();
  void removeAll();
}

/// Lightweight implementation of [InjectorBase] without external DI framework dependencies.
///
/// Supports lazy singletons and factory registration. Automatically invokes [BlocBase.close()]
/// during [removeAll()] to ensure zero background stream leaks.
class ModuleInjector implements InjectorBase {
  final Map<Type, Object Function()> _factories = {};
  final Map<Type, Object> _singletons = {};

  void addLazySingleton<T extends Object>(T Function() factory) {
    _factories[T] = () {
      if (!_singletons.containsKey(T)) {
        _singletons[T] = factory();
      }
      return _singletons[T]!;
    };
  }

  void addFactory<T extends Object>(T Function() factory) {
    _factories[T] = factory;
  }

  @override
  T get<T>() {
    final factory = _factories[T];
    if (factory != null) {
      return factory() as T;
    }
    final singleton = _singletons[T];
    if (singleton != null) {
      return singleton as T;
    }
    throw StateError('Dependency of type $T has not been registered in this module.');
  }

  @override
  void initialize() {}

  @override
  void removeAll() {
    for (final instance in _singletons.values) {
      if (instance is BlocBase) {
        instance.close();
      }
    }
    _singletons.clear();
    _factories.clear();
  }
}
