import 'package:freezed_annotation/freezed_annotation.dart';
import '../../core/database/tables.dart';

part 'task.freezed.dart';
part 'task.g.dart';

@freezed
class Task with _$Task {
  const factory Task({
    required String id,
    required String title,
    String? description,
    DateTime? dueDate,
    DateTime? dueTime,
    @Default(Priority.medium) Priority priority,
    @Default(false) bool isCompleted,
    @Default(false) bool isRepeating,
    RepeatType? repeatType,
    @Default(false) bool reminderEnabled,
    DateTime? createdAt,
    DateTime? completedAt,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  factory Task.fromDatabase(drift.Task dbTask) {
    return Task(
      id: dbTask.id,
      title: dbTask.title,
      description: dbTask.description,
      dueDate: dbTask.dueDate != null
          ? DateTime.fromMillisecondsSinceEpoch(dbTask.dueDate!)
          : null,
      dueTime: dbTask.dueTime != null
          ? DateTime.fromMillisecondsSinceEpoch(dbTask.dueTime!)
          : null,
      priority: dbTask.priority,
      isCompleted: dbTask.isCompleted,
      isRepeating: dbTask.isRepeating,
      repeatType: dbTask.repeatType,
      reminderEnabled: dbTask.reminderEnabled,
      createdAt: dbTask.createdAt,
      completedAt: dbTask.completedAt,
    );
  }
}

extension TaskExtension on Task {
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    final now = DateTime.now();
    final due = dueDate!;
    if (dueTime != null) {
      final dueDateTime = DateTime(
        due.year,
        due.month,
        due.day,
        dueTime!.hour,
        dueTime!.minute,
      );
      return now.isAfter(dueDateTime);
    }
    return now.isAfter(DateTime(due.year, due.month, due.day + 1));
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final due = dueDate!;
    return now.year == due.year &&
        now.month == due.month &&
        now.day == due.day;
  }

  String get formattedDueDate {
    if (dueDate == null) return '';
    final now = DateTime.now();
    final due = dueDate!;
    
    if (isDueToday) {
      if (dueTime != null) {
        final hour = dueTime!.hour.toString().padLeft(2, '0');
        final minute = dueTime!.minute.toString().padLeft(2, '0');
        return 'Today at $hour:$minute';
      }
      return 'Today';
    }
    
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    if (due.year == tomorrow.year &&
        due.month == tomorrow.month &&
        due.day == tomorrow.day) {
      if (dueTime != null) {
        final hour = dueTime!.hour.toString().padLeft(2, '0');
        final minute = dueTime!.minute.toString().padLeft(2, '0');
        return 'Tomorrow at $hour:$minute';
      }
      return 'Tomorrow';
    }
    
    final day = due.day.toString().padLeft(2, '0');
    final month = due.month.toString().padLeft(2, '0');
    final year = due.year;
    
    if (dueTime != null) {
      final hour = dueTime!.hour.toString().padLeft(2, '0');
      final minute = dueTime!.minute.toString().padLeft(2, '0');
      return '$day/$month/$year at $hour:$minute';
    }
    
    return '$day/$month/$year';
  }

  DateTime? get notificationDateTime {
    if (!reminderEnabled || dueDate == null) return null;
    if (dueTime != null) {
      return DateTime(
        dueDate!.year,
        dueDate!.month,
        dueDate!.day,
        dueTime!.hour,
        dueTime!.minute,
      );
    }
    return DateTime(dueDate!.year, dueDate!.month, dueDate!.day, 9, 0);
  }
}
