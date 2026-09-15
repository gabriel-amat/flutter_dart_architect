import 'package:flutter/material.dart';
import '../controllers/task_controller.dart';
import '../models/task_model.dart';

class TaskPage extends StatefulWidget {
  final TaskController controller;

  const TaskPage({super.key, required this.controller});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.controller.loadTasks();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onAdd() {
    widget.controller.addTask(_textController.text);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks (Small App Tier)'),
        elevation: 1,
      ),
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          if (widget.controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks = widget.controller.value;

          return Column(
            children: [
              _TaskInputField(
                controller: _textController,
                onSubmitted: _onAdd,
              ),
              Expanded(
                child: tasks.isEmpty
                    ? const Center(child: Text('No tasks registered yet.'))
                    : ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) => _TaskItemTile(
                          task: tasks[index],
                          onToggle: () => widget.controller.toggleTask(tasks[index].id),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TaskInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmitted;

  const _TaskInputField({
    required this.controller,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Add new task...',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => onSubmitted(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            icon: const Icon(Icons.add),
            onPressed: onSubmitted,
          ),
        ],
      ),
    );
  }
}

class _TaskItemTile extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onToggle;

  const _TaskItemTile({
    required this.task,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: task.isCompleted,
      title: Text(
        task.title,
        style: TextStyle(
          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          color: task.isCompleted ? Colors.grey : null,
        ),
      ),
      onChanged: (_) => onToggle(),
    );
  }
}
