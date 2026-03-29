

enum TaskStatus {
  todo('todo', 'To-Do'),
  inProgress('in_progress', 'In Progress'),
  done('done', 'Done');

  final String value;
  final String label;
  const TaskStatus(this.value, this.label);

  static TaskStatus fromValue(String value) =>
      TaskStatus.values.firstWhere((s) => s.value == value,
          orElse: () => TaskStatus.todo);
}

class Task {
  final int id;
  final String title;
  final String description;
  final DateTime? dueDate;
  final TaskStatus status;
  final int? blockedById;
  final int position;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
    required this.id,
    required this.title,
    this.description = '',
    this.dueDate,
    this.status = TaskStatus.todo,
    this.blockedById,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as int,
        title: json['title'] as String,
        description: (json['description'] as String?) ?? '',
        dueDate: json['due_date'] != null
            ? DateTime.parse(json['due_date'] as String)
            : null,
        status: TaskStatus.fromValue(json['status'] as String),
        blockedById: json['blocked_by_id'] as int?,
        position: json['position'] as int,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

}

