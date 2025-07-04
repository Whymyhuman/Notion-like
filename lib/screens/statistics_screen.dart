import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notion_like_app/providers/task_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Tasks: ${taskProvider.totalTasks}', style: const TextStyle(fontSize: 18)),
            Text('Completed Tasks: ${taskProvider.completedTasks}', style: const TextStyle(fontSize: 18, color: Colors.green)),
            Text('Pending Tasks: ${taskProvider.pendingTasks}', style: const TextStyle(fontSize: 18, color: Colors.orange)),
          ],
        ),
      ),
    );
  }
}


