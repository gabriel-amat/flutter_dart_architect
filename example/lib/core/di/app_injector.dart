/// Abstraction for dependency injection container.
abstract interface class AppInjector {
  void registerSingleton<T extends Object>(T Function() factory);
  void registerLazySingleton<T extends Object>(T Function() factory);
  void registerFactory<T extends Object>(T Function() factory);
  T get<T extends Object>();
  void reset();
  void commit();
}
