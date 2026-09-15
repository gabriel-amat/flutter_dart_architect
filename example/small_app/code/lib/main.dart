import 'package:flutter/material.dart';
import 'features/task/controllers/task_controller.dart';
import 'features/task/pages/task_page.dart';
import 'features/task/repositories/task_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Simple, direct manual dependency injection by feature
  final repository = TaskRepository();
  final controller = TaskController(repository);

  runApp(SmallApp(controller: controller));
}

class SmallApp extends StatelessWidget {
  final TaskController controller;

  const SmallApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Small App Example',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: TaskPage(controller: controller),
    );
  }
}
