import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';

/// Lightweight controller managing reactive state via Flutter's built-in ValueNotifier.
class TaskController extends ValueNotifier<List<TaskModel>> {
  final TaskRepository _repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  TaskController(this._repository) : super([]);

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    value = await _repository.getTasks();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask(String title) async {
    if (title.trim().isEmpty) return;
    final newTask = await _repository.addTask(title.trim());
    value = [...value, newTask];
  }

  Future<void> toggleTask(String id) async {
    await _repository.toggleTask(id);
    value = value.map((task) {
      if (task.id == id) {
        return task.copyWith(isCompleted: !task.isCompleted);
      }
      return task;
    }).toList();
  }
}
