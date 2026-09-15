import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_examples/controllers/user_profile_controller.dart';
import 'package:flutter_testing_examples/core/error/either.dart';
import 'package:flutter_testing_examples/core/error/failure.dart';
import 'package:flutter_testing_examples/models/user_model.dart';
import 'package:flutter_testing_examples/repositories/user_repository_impl.dart';
import 'package:flutter_testing_examples/usecases/get_user_profile_usecase.dart';

class MockUserRepository implements IUserRepository {
  Either<Failure, UserModel>? result;

  @override
  Future<Either<Failure, UserModel>> getUser(String id) async => result!;

  @override
  Future<Either<Failure, void>> updateScore(String id, int newScore) async =>
      const Right(null);
}

void main() {
  late MockUserRepository mockRepo;
  late GetUserProfileUseCase useCase;
  late UserProfileController controller;

  setUp(() {
    mockRepo = MockUserRepository();
    useCase = GetUserProfileUseCase(repository: mockRepo);
    controller = UserProfileController(getUserProfile: useCase);
  });

  group('Controller / State Transition Test', () {
    test('initial state should be UserProfileInitialState', () {
      expect(controller.value, isA<UserProfileInitialState>());
    });

    test('should emit [LoadingState, SuccessState] when fetching user succeeds', () async {
      const user = UserModel(
        id: 'usr-9',
        name: 'John Wayne',
        email: 'john@example.com',
        score: 150,
      );
      mockRepo.result = const Right(user);

      final stateHistory = <UserProfileState>[];
      controller.addListener(() {
        stateHistory.add(controller.value);
      });

      await controller.fetchUser('usr-9');

      expect(stateHistory.length, 2);
      expect(stateHistory[0], isA<UserProfileLoadingState>());
      expect(stateHistory[1], isA<UserProfileSuccessState>());
      final success = stateHistory[1] as UserProfileSuccessState;
      expect(success.user.name, 'John Wayne');
    });

    test('should emit [LoadingState, ErrorState] when fetching user fails', () async {
      mockRepo.result = const Left(ServerFailure(message: 'Connection timed out'));

      final stateHistory = <UserProfileState>[];
      controller.addListener(() {
        stateHistory.add(controller.value);
      });

      await controller.fetchUser('usr-error');

      expect(stateHistory.length, 2);
      expect(stateHistory[0], isA<UserProfileLoadingState>());
      expect(stateHistory[1], isA<UserProfileErrorState>());
      final error = stateHistory[1] as UserProfileErrorState;
      expect(error.message, 'Connection timed out');
    });
  });
}
