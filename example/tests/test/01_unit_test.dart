import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_examples/models/user_model.dart';

void main() {
  group('Unit Test: UserModel & Pure Dart Logic', () {
    test('should correctly instantiate and compare immutable models', () {
      // 1. Arrange
      const userA = UserModel(
        id: 'usr-1',
        name: 'Alice Johnson',
        email: 'alice@example.com',
        score: 100,
      );
      const userB = UserModel(
        id: 'usr-1',
        name: 'Alice Johnson',
        email: 'alice@example.com',
        score: 100,
      );

      // 2. Act & Assert (Equality by value)
      expect(userA, equals(userB));
      expect(userA.hashCode, equals(userB.hashCode));
    });

    test('should correctly deserialize from JSON map', () {
      final json = {
        'id': 'usr-2',
        'name': 'Bob Smith',
        'email': 'bob@example.com',
        'score': 250,
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 'usr-2');
      expect(user.name, 'Bob Smith');
      expect(user.email, 'bob@example.com');
      expect(user.score, 250);
    });

    test('should copyWith updated fields while preserving untouched fields', () {
      const original = UserModel(
        id: 'usr-3',
        name: 'Charlie',
        email: 'charlie@example.com',
        score: 50,
      );

      final updated = original.copyWith(score: 80);

      expect(updated.score, 80);
      expect(updated.name, 'Charlie');
      expect(updated.id, 'usr-3');
    });
  });
}
