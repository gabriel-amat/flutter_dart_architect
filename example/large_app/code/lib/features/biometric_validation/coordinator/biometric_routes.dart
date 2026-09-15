enum BiometricRoutes {
  base('/'),
  capture('/capture');

  const BiometricRoutes(this.path);
  final String path;
}
