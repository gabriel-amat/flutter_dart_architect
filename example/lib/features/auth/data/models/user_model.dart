import '../../domain/entities/user_entity.dart';

/// Dart 3.3+ Extension Type wrapping and implementing UserEntity.
/// Provides zero runtime overhead while strictly isolating serialization to the Data Layer.
extension type UserModel(UserEntity entity) implements UserEntity {
  factory UserModel.fromEntity(UserEntity entity) => UserModel(entity);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      UserEntity(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        token: json['token'] as String? ?? json['access_token'] as String? ?? '',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
    };
  }
}
