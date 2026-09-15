import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_examples/core/error/either.dart';
import 'package:flutter_testing_examples/core/error/failure.dart';
import 'package:flutter_testing_examples/models/user_model.dart';
import 'package:flutter_testing_examples/repositories/user_repository_impl.dart';
import 'package:flutter_testing_examples/usecases/get_user_profile_usecase.dart';

// Lightweight, zero-dependency manual mock for repository
class MockUserRepository implements IUserRepository {
  Either<Failure, UserModel>? mockUserResult;

  @override
  Future<Either<Failure, UserModel>> getUser(String id) async {
    return mockUserResult!;
  }

  @override
  Future<Either<Failure, void>> updateScore(String id, int newScore) async {
    return const Right(null);
  }
}

void main() {
  late MockUserRepository mockRepository;
  late GetUserProfileUseCase useCase;

  setUp(() {
    mockRepository = MockUserRepository();
    useCase = GetUserProfileUseCase(repository: mockRepository);
  });

  group('UseCase Test: GetUserProfileUseCase with Functional Either', () {
    test('should return ValidationFailure without calling repository when userId is blank', () async {
      // Act
      final result = await useCase('   ');

      // Assert
      expect(result.isLeft, isTrue);
      expect(result.leftOrNull, isA<ValidationFailure>());
      expect(result.leftOrNull?.message, 'User ID cannot be empty.');
    });

    test('should return Right(UserModel) when repository call succeeds', () async {
      // Arrange
      const expectedUser = UserModel(
        id: '123',
        name: 'Jane Doe',
        email: 'jane@example.com',
        score: 400,
      );
      mockRepository.mockUserResult = const Right(expectedUser);

      // Act
      final result = await useCase('123');

      // Assert
      expect(result.isRight, isTrue);
      expect(result.rightOrNull, equals(expectedUser));
    });

    test('should return Left(ServerFailure) when repository fails', () async {
      // Arrange
      mockRepository.mockUserResult = const Left(ServerFailure(
        message: 'Internal server error',
        statusCode: 500,
      ));

      // Act
      final result = await useCase('123');

      // Assert
      expect(result.isLeft, isTrue);
      expect(result.leftOrNull, isA<ServerFailure>());
      expect(result.leftOrNull?.statusCode, 500);
    });
  });
}
