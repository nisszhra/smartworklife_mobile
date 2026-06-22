/// Model yang memetakan response JSON dari backend endpoint /todos/*
class TodoModel {
  final String id;
  final String title;
  final String description;
  final String priority; // "important" | "normal"
  final String status;   // "pending" | "done"
  final DateTime? deadline;
  final DateTime? taskDate;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  TodoModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.priority,
    required this.status,
    this.deadline,
    this.taskDate,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isCompleted => status == 'done';
  bool get isPriority => priority == 'important';

  bool get isOverdue {
    if (isCompleted) return false;
    if (deadline == null) return false;
    return deadline!.isBefore(DateTime.now());
  }

  bool get isExtended {
    return description.startsWith('[Perpanjangan]');
  }

  String get cleanDescription {
    if (description.startsWith('[Perpanjangan]')) {
      return description.replaceFirst('[Perpanjangan]', '').trim();
    }
    return description;
  }

  /// Label waktu yang ditampilkan di UI (deadline atau task_date)
  String get timeLabel {
    if (deadline != null) {
      final d = deadline!.toLocal();
      return '${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    }
    if (taskDate != null) {
      final d = taskDate!;
      return '${d.day}/${d.month}/${d.year}';
    }
    return '';
  }

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'].toString(),
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      priority: json['priority'] as String? ?? 'normal',
      status: json['status'] as String? ?? 'pending',
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      taskDate: json['task_date'] != null ? DateTime.parse(json['task_date']) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  TodoModel copyWith({
    String? status,
    String? priority,
    String? title,
    String? description,
    DateTime? deadline,
    DateTime? taskDate,
  }) {
    return TodoModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      deadline: deadline ?? this.deadline,
      taskDate: taskDate ?? this.taskDate,
      completedAt: completedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
