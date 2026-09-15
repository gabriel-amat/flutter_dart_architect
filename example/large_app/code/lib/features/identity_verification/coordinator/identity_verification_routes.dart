enum IdentityVerificationRoutes {
  base('/'),
  document('/document'),
  biometrics('/biometrics');

  const IdentityVerificationRoutes(this.path);
  final String path;
}
