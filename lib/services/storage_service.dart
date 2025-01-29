import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_app/model/task_model.dart';

class StorageService {
  static const String _tasksKey = 'tasks';
  static const String _selectedFilterKey = 'selectedFilter';
  static const String _selectedCategoryKey = 'selectedCategory';

  // Save tasks to SharedPreferences
  Future<void> saveTasks(List<TaskModel> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = tasks.map((task) => jsonEncode(task.toMap())).toList();
    await prefs.setStringList(_tasksKey, tasksJson);
  }

  // Load tasks from SharedPreferences
  Future<List<TaskModel>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList(_tasksKey) ?? [];
    return tasksJson.map((task) => TaskModel.fromMap(jsonDecode(task))).toList();
  }

  // Save selected filter preferences (status) to SharedPreferences
  Future<void> saveFilterPreferences(List<String> selectedFilter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_selectedFilterKey, selectedFilter);
  }

  // Load selected filter preferences (status) from SharedPreferences
  Future<List<String>> loadFilterPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_selectedFilterKey) ?? [];
  }

  // Save selected category preferences to SharedPreferences
  Future<void> saveCategoryPreferences(List<String> selectedCategory) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_selectedCategoryKey, selectedCategory);
  }

  // Load selected category preferences from SharedPreferences
  Future<List<String>> loadCategoryPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_selectedCategoryKey) ?? [];
  }
}
