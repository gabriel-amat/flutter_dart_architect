import '../models/task_model.dart';

/// Pragmatic repository for small apps, handling direct HTTP or local caching.
class TaskRepository {
  // In-memory mock storage for demonstration
  final List<TaskModel> _mockStorage = [
    const TaskModel(id: '1', title: 'Study Flutter Clean Architecture', isCompleted: true),
    const TaskModel(id: '2', title: 'Configure flutter-dart-architect spec', isCompleted: false),
    const TaskModel(id: '3', title: 'Write LinkedIn tech overview', isCompleted: false),
  ];

  Future<List<TaskModel>> getTasks() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_mockStorage);
  }

  Future<TaskModel> addTask(String title) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final newTask = TaskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
    );
    _mockStorage.add(newTask);
    return newTask;
  }

  Future<void> toggleTask(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _mockStorage.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _mockStorage[index];
      _mockStorage[index] = task.copyWith(isCompleted: !task.isCompleted);
    }
  }
}
