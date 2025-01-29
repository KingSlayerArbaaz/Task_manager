class TaskModel {
  String title;
  String? description;
  DateTime dueDate;
  bool isCompleted;
  String category;

  TaskModel({
    required this.title,
    this.description,
    required this.dueDate,
    this.isCompleted = false,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'category': category,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      title: map['title'] ?? '', // Default to empty string if no title
      description: map['description'], // Nullable field, no default
      dueDate: DateTime.parse(map['dueDate'] ), // Parse only if 'dueDate' is not null
      isCompleted: map['isCompleted'] ?? false, // Default to false if missing
      category: map['category'], 
    );
  }
}
