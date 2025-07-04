
import 'package:flutter/material.dart';
import 'package:notion_like_app/models/task.dart';
import 'package:notion_like_app/services/database_service.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  final DatabaseService _databaseService = DatabaseService();

  List<Task> get tasks => _tasks;

  TaskProvider() {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    _tasks = await _databaseService.getTasks();
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await _databaseService.insertTask(task);
    await _loadTasks();
  }

  Future<void> updateTask(Task task) async {
    await _databaseService.updateTask(task);
    await _loadTasks();
  }

  Future<void> deleteTask(int id) async {
    await _databaseService.deleteTask(id);
    await _loadTasks();
  }

  Future<void> toggleTaskStatus(Task task) async {
    task.isCompleted = !task.isCompleted;
    await _databaseService.updateTask(task);
    await _loadTasks();
  }

  List<Task> getFilteredTasks({
    String? searchQuery,
    int? categoryId,
    int? priority,
    bool? isCompleted,
  }) {
    return _tasks.where((task) {
      final matchesSearch = searchQuery == null ||
          task.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          task.description.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesCategory = categoryId == null || task.categoryId == categoryId;
      final matchesPriority = priority == null || task.priority == priority;
      final matchesCompletion = isCompleted == null || task.isCompleted == isCompleted;

      return matchesSearch && matchesCategory && matchesPriority && matchesCompletion;
    }).toList();
  }

  int get totalTasks => _tasks.length;
  int get completedTasks => _tasks.where((task) => task.isCompleted).length;
  int get pendingTasks => _tasks.where((task) => !task.isCompleted).length;
}

