import 'package:flutter/material.dart';
import 'package:to_do_app/model/task_model.dart';

class StatisticsByCategoryScreen extends StatelessWidget {
  final List<TaskModel> tasks;

  const StatisticsByCategoryScreen({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    // Group tasks by category
    Map<String, List<TaskModel>> tasksByCategory = {};
    for (var task in tasks) {
      tasksByCategory.putIfAbsent(task.category, () => []).add(task);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics by Category'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal, 
          child: Row(
            children: [
              DataTable(
                columns: const [
                  DataColumn(label: Text('Category')),
                  DataColumn(label: Text('Total Tasks')),
                  DataColumn(label: Text('Pending')),
                  DataColumn(label: Text('Completed')),
                ],
                rows: tasksByCategory.entries.map((entry) {
                  String category = entry.key;
                  List<TaskModel> categoryTasks = entry.value;

                  
                  int total = categoryTasks.length;
                  int pending = categoryTasks.where((task) => !task.isCompleted).length;
                  int completed = total - pending;

                  return DataRow(cells: [
                    DataCell(Text(category)),
                    DataCell(Text(total.toString())),
                    DataCell(Text(pending.toString())),
                    DataCell(Text(completed.toString())),
                  ]);
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
