import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';

class TaskProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Task> get pendingTasks => _tasks.where((task) => task.status == 'pending').toList();
  List<Task> get inProgressTasks => _tasks.where((task) => task.status == 'in_progress').toList();
  List<Task> get completedTasks => _tasks.where((task) => task.status == 'completed').toList();

  Future<void> fetchTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await _apiService.getTasks();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch tasks: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTask(Task task) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newTask = await _apiService.createTask(task);
      _tasks.add(newTask);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to create task: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTaskStatus(int taskId, String newStatus) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Find the task to update
      final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex == -1) {
        _error = 'Task not found';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Create updated task
      final updatedTask = _tasks[taskIndex].copyWith(status: newStatus);
      
      // Update on server
      final result = await _apiService.updateTask(taskId, updatedTask);
      
      // Update local list
      _tasks[taskIndex] = result;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update task: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
