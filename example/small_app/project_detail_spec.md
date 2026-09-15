# 🟢 Small App Tier Specification (`small_app`)

### Fast, Clean & Pragmatic Flutter Architecture for MVPs & Utilities
*Maintainer: Gabriel Amat | Target: Dart 3.3+ / Flutter 3.19+*

---

## 🎯 Philosophy: Avoid the "Over-Engineering Trap"

When building small apps, prototypes, internal tools, or MVPs (1 to 5 screens):
- **You do NOT need** complex multi-layer abstractions (`Domain/UseCase/RepositoryInterface/RepositoryImpl/DataSource/DTO/Entity`).
- **You do NOT need** heavy third-party state management libraries.
- Creating 6 files to fetch a simple JSON list slows down delivery without adding any real value.

The **Small App** standard enforces **Clean, Single-Responsibility Code** using Flutter's built-in capabilities.

---

## 📁 Directory Structure (Feature-First)

Even in small applications, organizing code by **Features** (`features/`) prevents loose files from cluttering the root and provides a smooth transition path to the Medium tier as the codebase grows:

```
lib/
 ├─ features/
 │   └─ task/
 │       ├─ controllers/
 │       │   └─ task_controller.dart   # ValueNotifier for reactive state management
 │       ├─ models/
 │       │   └─ task_model.dart        # Immutable data structure with fromJson/toJson
 │       ├─ pages/
 │       │   └─ task_page.dart         # UI screen with clean widget decomposition
 │       └─ repositories/
 │           └─ task_repository.dart   # Direct repository (HTTP / Storage) without UseCase/DataSource
 └─ main.dart                          # Lean dependency injection & app startup
```

---

## ⚡ The 4 Core Rules of the Small Tier

### 1. State Management: Built-in `ValueNotifier<T>`
Use Flutter's native `ValueNotifier<T>` and `ValueListenableBuilder<T>`. Zero third-party dependencies, garbage-collector friendly, and crystal clear.

```dart
class TaskController extends ValueNotifier<List<TaskModel>> {
  final TaskRepository _repository;
  TaskController(this._repository) : super([]);

  bool isLoading = false;

  Future<void> loadTasks() async {
    isLoading = true;
    notifyListeners();
    value = await _repository.getTasks();
    isLoading = false;
    notifyListeners();
  }
}
```

### 2. Flat Data Access
A single `Repository` class handles API communication directly. When business logic is minimal CRUD, creating separate `UseCase` and `DataSource` files is an anti-pattern.

### 3. Immutable Models
Use simple immutable models with `const` constructors and clean serialization.

### 4. Widget Decomposition
Avoid large build methods. Break the screen into focused private `StatelessWidget` classes.

---

## 🤖 Instructions for AI Coding Assistants (Small Tier Mode)

When prompted to build or refactor a **Small Tier** app, the AI must:
1. Keep the total file count minimal and maintainable.
2. Use native `ValueNotifier` or `ChangeNotifier` for state.
3. Not generate UseCases, abstract interfaces, or complex DI packages unless explicitly requested.
4. Keep all models immutable and strongly typed.
