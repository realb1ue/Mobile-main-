import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../utils/db_helper.dart';

final log = Logger();

class ToDoListApp extends StatefulWidget {
  const ToDoListApp({super.key});

  @override
  State createState() => _ToDoListAppState();
}

class _ToDoListAppState extends State<ToDoListApp> {
  final TextEditingController _taskController = TextEditingController();
  List<Map<String, dynamic>> _tasks = [];
  List<bool> checkboxValues = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  /// Load tasks from database
  void _loadTasks() async {
    final data = await DBHelper.instance.getTasks();
    setState(() {
      _tasks = data;
      checkboxValues = data.map<bool>((e) => e['isDone'] == 1).toList();
    });
  }

  /// Add new task
  void _addTask() async {
    final text = _taskController.text.trim();
    if (text.isEmpty) return;

    await DBHelper.instance.addTask(text);
    _taskController.clear();
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _taskController,
                  decoration: InputDecoration(
                    labelText: 'Add a new task',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addTask,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(14),
                ),
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            itemCount: _tasks.length,
            itemBuilder: (context, index) {
              final task = _tasks[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: CheckboxListTile(
                  title: Text(task['title'],
                      style: TextStyle(
                        fontSize: 16,
                        decoration: checkboxValues[index]
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      )),
                  value: checkboxValues[index],
                  onChanged: (bool? value) async {
                    int updatedStatus = await DBHelper.instance
                        .updateTask(task['id'], value! ? 1 : 0);

                    setState(() {
                      checkboxValues[index] = value;
                    });

                    log.d('Task updated: $updatedStatus');
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
