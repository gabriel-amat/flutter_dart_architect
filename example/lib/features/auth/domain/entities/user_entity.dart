/// Pure Domain Entity. Never contains JSON parsing or Flutter imports.
class UserEntity {
  final String id;
  final String name;
  final String email;
  final String token;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
  });
}
