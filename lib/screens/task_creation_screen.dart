import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskCreationScreen extends StatefulWidget {
  final Function(String, String?, DateTime,String) onSave;
  final String initialTitle;
  final String? initialDescription;
  final DateTime? initialDueDate;
  final String initialCategory;

  const TaskCreationScreen({
    super.key,
    required this.onSave,
    this.initialTitle = '',
    this.initialDescription,
    required this.initialDueDate,
     required this.initialCategory,
  });

  @override
  // ignore: library_private_types_in_public_api
  _TaskCreationScreenState createState() => _TaskCreationScreenState();
}

class _TaskCreationScreenState extends State<TaskCreationScreen> {
  
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
   DateTime? _dueDate;
   String? _selectedCategory;

  final List<String> _categories = ['Work', 'Personal', 'Shopping', 'Other'];

  @override
  void initState() {
    super.initState();
    // Initialize the controllers with the initial values passed from TaskListScreen
    _titleController.text = widget.initialTitle;
    _descriptionController.text = widget.initialDescription ?? '';
    _dueDate = widget.initialDueDate;
    _selectedCategory = widget.initialCategory;
  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create / Edit Task')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,),
              const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  final pickedTime = await showTimePicker(
                    // ignore: use_build_context_synchronously
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      _dueDate = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                    });
                  }
                }
              },
              child: Center(
                child: Text(_dueDate == null
                    ? 'Select Due Date & Time'
                    : 'Due Date: ${DateFormat('MM/dd/yyyy hh:mm a').format(_dueDate!)}',style: const TextStyle(color: Colors.blueAccent),),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: 
              
              _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            
            // const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 29.0),
              child: ElevatedButton(
                onPressed: _titleController.text.isNotEmpty && _dueDate != null
                    ? () {
                        widget.onSave(
                          _titleController.text,
                          _descriptionController.text,
                          _dueDate!,
                          _selectedCategory!
                        );
                        Navigator.pop(context);
                      }
                    : null,
                child: const Center(child: Text('Save')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
