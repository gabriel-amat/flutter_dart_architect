import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_examples/controllers/user_profile_controller.dart';
import 'package:flutter_testing_examples/core/error/either.dart';
import 'package:flutter_testing_examples/core/error/failure.dart';
import 'package:flutter_testing_examples/models/user_model.dart';
import 'package:flutter_testing_examples/repositories/user_repository_impl.dart';
import 'package:flutter_testing_examples/usecases/get_user_profile_usecase.dart';
import 'package:flutter_testing_examples/widgets/user_card_widget.dart';

// Sample 2-screen mini-flow for testing end-to-end user navigation
class UserSearchPage extends StatefulWidget {
  final UserProfileController controller;
  const UserSearchPage({super.key, required this.controller});

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  final _inputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search User')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _inputController,
              decoration: const InputDecoration(labelText: 'Enter User ID'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await widget.controller.fetchUser(_inputController.text);
                if (context.mounted && widget.controller.value is UserProfileSuccessState) {
                  final state = widget.controller.value as UserProfileSuccessState;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => UserDetailsPage(user: state.user),
                    ),
                  );
                }
              },
              child: const Text('Search'),
            ),
          ],
        ),
      ),
    );
  }
}

class UserDetailsPage extends StatelessWidget {
  final UserModel user;
  const UserDetailsPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Details')),
      body: Center(
        child: UserCardWidget(user: user),
      ),
    );
  }
}

class MockRepo implements IUserRepository {
  @override
  Future<Either<Failure, UserModel>> getUser(String id) async {
    return const Right(UserModel(
      id: 'USR-77',
      name: 'Ellen Ripley',
      email: 'ripley@nostromo.org',
      score: 999,
    ));
  }

  @override
  Future<Either<Failure, void>> updateScore(String id, int newScore) async => const Right(null);
}

void main() {
  group('Integration / Flow Test: User Search & Navigation', () {
    testWidgets('should search for user and navigate to details screen', (tester) async {
      final controller = UserProfileController(
        getUserProfile: GetUserProfileUseCase(repository: MockRepo()),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: UserSearchPage(controller: controller),
        ),
      );

      // Verify screen 1 is displayed
      expect(find.text('Search User'), findsOneWidget);

      // Enter user ID
      await tester.enterText(find.byType(TextField), 'USR-77');
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      // Verify screen 2 is pushed
      expect(find.text('User Details'), findsOneWidget);
      expect(find.text('Ellen Ripley'), findsOneWidget);
      expect(find.text('ripley@nostromo.org'), findsOneWidget);

      // Pop back to screen 1
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Search User'), findsOneWidget);
      expect(find.text('User Details'), findsNothing);
    });
  });
}
