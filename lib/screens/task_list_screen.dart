import 'package:flutter/material.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_app/model/task_model.dart';
import 'package:to_do_app/screens/StatisticsByCategoryScreen.dart';
import 'package:to_do_app/services/notification_service.dart';
import '../services/storage_service.dart';
import 'task_creation_screen.dart';
import 'package:intl/intl.dart';

class TaskListScreen extends StatefulWidget {
  final Function(bool) onThemeChange;
  const TaskListScreen({super.key, required this.onThemeChange});

  @override
  // ignore: library_private_types_in_public_api
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _storageService = StorageService();
  final _notificationService = NotificationService();
  List<TaskModel> _tasks = [];
  bool _isDarkMode = false;
  List<TaskModel> _filteredTasks = [];
  List<String> selectedFilter = [];
  List<String> selectedCategory = [];

  // List of categories
  final List<String> _categories = ['Other', 'Work', 'Personal', 'Shopping'];
  final List<String> _filters = ['All', 'Pending', 'Completed'];
// Calculate statistics
  int get totalTasks => _filteredTasks.length;
  int get pendingTasks =>
      _filteredTasks.where((task) => !task.isCompleted).length;
  int get completedTasks =>
      _filteredTasks.where((task) => task.isCompleted).length;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _notificationService.initialize();
    _notificationService.requestPermissions();
    _loadThemePreference();
    _loadFilters();
  }

  Future<void> _loadFilters() async {
  selectedFilter = await _storageService.loadFilterPreferences();
  selectedCategory = await _storageService.loadCategoryPreferences();

  // After loading, apply the filter to the tasks
  _filterTasks();
}

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  Future<void> _saveThemePreference(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', isDarkMode);
  }

  Future<void> _loadTasks() async {
    final tasks = await _storageService.loadTasks();
    setState(() {
      _tasks = tasks;
      _filteredTasks = tasks;
    });
  }


void _filterTasks() async {
  setState(() {
    _filteredTasks = _tasks;

    // Filter by Status
    if (selectedFilter.isNotEmpty) {
      if (selectedFilter.contains('Pending') ) {
        _filteredTasks = _filteredTasks.where((task) => !task.isCompleted).toList();
      }
      if (selectedFilter.contains('Completed')) {
        _filteredTasks = _filteredTasks.where((task) => task.isCompleted).toList();
      }
      // _filteredTasks=_filteredTasks.where((task) => task.isCompleted).toList();
    }

    // Filter by Category
    if (selectedCategory.isNotEmpty) {
      _filteredTasks = _filteredTasks.where((task) => selectedCategory.contains(task.category)).toList();
    }


  },
  );
    await _storageService.saveCategoryPreferences(selectedCategory);
    await _storageService.saveFilterPreferences(selectedFilter);
}

void _searchTasks(String query) {

setState(() {
  
  _searchQuery = query; // Update the search query
   _filteredTasks = _tasks
          .where(
              (task) => task.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    
  // _filterTasks(); // Reapply the filters with the new search query
});

}




// Define your filters'; // Filter by category
  // ignore: unused_field
  String _searchQuery = ''; // Current search query


  Future<void> _addTask(String title, String? description, DateTime dueDate,
      String category) async {
    final newTask = TaskModel(
        title: title,
        description: description,
        dueDate: dueDate,
        category: category);
    setState(() => _tasks.add(newTask));
    await _storageService.saveTasks(_tasks); // Save the tasks after adding a new task
    _notificationService.showImmediateNotification(_tasks.length - 1,title);
    _notificationService.scheduleNotification(
      _tasks.length - 1,
      title,
      dueDate,
    );
    _filterTasks(); // filter tasks after adding a new task
  }

  Future<void> _deleteTask(int index) async {
    setState(() => _tasks.removeAt(index));
    await _storageService.saveTasks(_tasks);
    _notificationService.cancelNotification(index);
  }

  Future<void> _editTask(TaskModel task) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskCreationScreen(
          onSave: (title, description, dueDate, category) async {
            // Update the task with the new values
            task.title = title;
            task.description = description;
            task.dueDate = dueDate;
            task.category = category;

            setState(() {
              // Refresh the UI after updating the task
            });

            await _storageService.saveTasks(_tasks);

            // Schedule notification after saving the task
            await _notificationService.scheduleNotification(
              _tasks.length - 1, // Task ID to ensure correct ID is used
              task.title,
              task.dueDate,
            );
          },
          initialTitle: task.title,
          initialDescription: task.description,
          initialDueDate: task.dueDate,
          initialCategory: task.category,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          Switch(
            value: _isDarkMode,
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
              });
              _saveThemePreference(_isDarkMode);
              widget.onThemeChange(_isDarkMode);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _searchTasks,
              decoration: InputDecoration(
                hintText: 'Search tasks by title...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _openFilter,
                ),
              ),
            ),
          ),

          // Task Statistics Section
GestureDetector(
  onDoubleTap: () {
    // Navigate to the statistics by category screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StatisticsByCategoryScreen(tasks: _tasks)),
    );
  },
  child: Container(
    padding: const EdgeInsets.all(16),
    color: Colors.blueAccent,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatItem('Total Tasks', totalTasks),
        _buildStatItem('Pending Tasks', pendingTasks),
        _buildStatItem('Completed Tasks', completedTasks),
      ],
    ),
  ),
),

          // Task List
          Expanded(
            child: ListView.builder(
              itemCount: _filteredTasks.length,
              itemBuilder: (context, index) {
                final task = _filteredTasks[index];
                return Dismissible(
                  key: Key(task.title),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) async {
                    await _deleteTask(index);
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${task.title} deleted')),
                    );
                  },
                  background: Container(
                    color: Colors.red,
                    child: const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 20.0),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                    ),
                  ),
                  child: ListTile(
                    title: Text(task.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Due: ${DateFormat('MM/dd/yyyy hh:mm a').format(task.dueDate.toLocal())}',
                        ),
                        Text(
                          'Category: ${task.category}', // Display the category here
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: Checkbox(
                      value: task.isCompleted,
                      onChanged: (value) async {
                        setState(() => task.isCompleted = value!);
                        await _storageService.saveTasks(_tasks);
                        _notificationService.cancelNotification(index);
                      },
                    ),
                    onTap: () => _editTask(task),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        // foregroundColor: Colors.red,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskCreationScreen(
              onSave: (title, description, dueDate, category) =>
                  _addTask(title, description, dueDate, category),
              initialTitle: '',
              initialDescription: null,
              initialDueDate: null,
              initialCategory: _categories.first,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value) // Display the category here
   {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
        Text(
          '$value',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }



    //Filter options
 void _openFilter() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Filter Options'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Theme(
  data: Theme.of(context).copyWith(
    dialogBackgroundColor: Theme.of(context).brightness == Brightness.dark
        ? const Color.fromARGB(255, 114, 107, 107)  // Dark mode background color (custom dark color)
        : Colors.white, // Light mode background color (custom light color)
      ),
  child: 
          MultiSelectDialogField(
            // backgroundColor: const Color.fromARGB(255, 114, 107, 107),
             dialogHeight: 200,
            dialogWidth: 200,
            items: _filters
                .map((status) => MultiSelectItem(status, status,))
                .toList(),
            title: const Text('Select Status'),
            buttonText: const Text('Filter by Status'),
            initialValue: selectedFilter,
            onConfirm: (values) =>
                setState(() => selectedFilter = List<String>.from(values)),             
          ),),
          
          const SizedBox(height: 10),
          Theme(
  data: Theme.of(context).copyWith(
    dialogBackgroundColor: Theme.of(context).brightness == Brightness.dark
        ? const Color.fromARGB(255, 114, 107, 107)  // Dark mode background color (custom dark color)
        : Colors.white, // Light mode background color (custom light color)
      ),
  child: MultiSelectDialogField(
    dialogHeight: 200,
    dialogWidth: 200,
    items: _categories
        .map((category) => MultiSelectItem(category, category))
        .toList(),
    title:const Text(
      'Select Status',
      
    ),
    buttonText:const Text(
      'Filter by Status',
      
    ),
    initialValue: selectedCategory,
    onConfirm: (values) => setState(
      () => selectedCategory = List<String>.from(values),
    ),
  ),
),

        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              selectedFilter.clear();
              selectedCategory.clear();
            });
            _filterTasks();
            Navigator.of(context).pop();
          },
          child: const Text(
            "Clear",
          ),
        ),
        TextButton(
  onPressed: () {
    _filterTasks();  // Call the filter logic here
    Navigator.of(context).pop();
  },
  child: const Text('Close'),
),
      ],
    ),
  );
}

}
