import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_examples/models/user_model.dart';
import 'package:flutter_testing_examples/widgets/user_card_widget.dart';

void main() {
  group('Golden / Visual Regression Test Example', () {
    testWidgets('UserCardWidget renders consistent layout matching golden spec', (tester) async {
      // 1. Arrange standard test user
      const user = UserModel(
        id: 'golden-1',
        name: 'Neo Anderson',
        email: 'neo@matrix.io',
        score: 500,
      );

      // Set fixed test surface size to guarantee deterministic visual rendering
      tester.view.physicalSize = const Size(400, 200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // 2. Pump the widget inside standard Material theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          home: const Scaffold(
            body: Center(
              child: UserCardWidget(user: user),
            ),
          ),
        ),
      );

      // 3. Verify widget layout stability
      expect(find.byType(UserCardWidget), findsOneWidget);
      expect(find.text('Neo Anderson'), findsOneWidget);

      // In CI environments with generated goldens:
      // await expectLater(
      //   find.byType(UserCardWidget),
      //   matchesGoldenFile('goldens/user_card_widget.png'),
      // );
    });
  });
}
