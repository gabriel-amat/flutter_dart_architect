import 'app_injector.dart';

/// Centralized ServiceLocator singleton wrapper.
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late final AppInjector _injector;

  void setup(AppInjector injector) {
    _injector = injector;
  }

  T get<T extends Object>() => _injector.get<T>();
}

final locator = ServiceLocator();
