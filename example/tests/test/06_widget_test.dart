import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_examples/models/user_model.dart';
import 'package:flutter_testing_examples/widgets/user_card_widget.dart';

void main() {
  group('Widget Test: UserCardWidget Rendering & User Interactions', () {
    testWidgets('should render user name, email, score and avatar initial', (tester) async {
      const user = UserModel(
        id: '1',
        name: 'Sarah Connor',
        email: 'sarah@resistance.org',
        score: 777,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserCardWidget(user: user),
          ),
        ),
      );

      // Verify text elements
      expect(find.text('Sarah Connor'), findsOneWidget);
      expect(find.text('sarah@resistance.org'), findsOneWidget);
      expect(find.text('Score: 777'), findsOneWidget);

      // Verify avatar initial
      expect(find.text('S'), findsOneWidget);

      // Action button should NOT be rendered when callback is null
      expect(find.byKey(const Key('user_card_action_button')), findsNothing);
    });

    testWidgets('should trigger onActionPressed callback when button is tapped', (tester) async {
      const user = UserModel(
        id: '2',
        name: 'Kyle Reese',
        email: 'kyle@future.net',
        score: 300,
      );

      int tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserCardWidget(
              user: user,
              onActionPressed: () => tapCount++,
            ),
          ),
        ),
      );

      final actionButton = find.byKey(const Key('user_card_action_button'));
      expect(actionButton, findsOneWidget);

      // Simulate tap
      await tester.tap(actionButton);
      await tester.pump();

      expect(tapCount, 1);
    });
  });
}
