class UserModel {
  final String id;
  final String name;
  final String email;
  final int score;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.score = 0,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    int? score,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      score: score ?? this.score,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      score: json['score'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'score': score,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          score == other.score;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ email.hashCode ^ score.hashCode;
}
