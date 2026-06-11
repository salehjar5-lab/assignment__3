// Model class representing a task in the database
class Task {
  final int? id;
  final String title;
  final String description;
  final int isComplete; // 0 = Not Completed, 1 = Completed

  Task({
    this.id,
    required this.title,
    required this.description,
    this.isComplete = 0,
  });

  // Convert Task to Map for SQLite insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isComplete': isComplete,
    };
  }

  // Create Task from Map returned by SQLite
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isComplete: map['isComplete'],
    );
  }

  // Helper to check if task is completed
  bool get isDone => isComplete == 1;

  // Create a copy of Task with updated fields
  Task copyWith({
    int? id,
    String? title,
    String? description,
    int? isComplete,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}
