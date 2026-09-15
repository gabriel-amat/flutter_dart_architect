import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:small_app_example/features/task/controllers/task_controller.dart';
import 'package:small_app_example/features/task/pages/task_page.dart';
import 'package:small_app_example/features/task/repositories/task_repository.dart';

void main() {
  testWidgets('Small app task list and add flow test', (tester) async {
    final repository = TaskRepository();
    final controller = TaskController(repository);

    await tester.pumpWidget(
      MaterialApp(
        home: TaskPage(controller: controller),
      ),
    );

    // Initial loading indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    // Verify initial mock tasks are loaded
    expect(find.text('Study Flutter Clean Architecture'), findsOneWidget);

    // Add a new task
    await tester.enterText(find.byType(TextField), 'Test feature separation');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('Test feature separation'), findsOneWidget);
  });
}
