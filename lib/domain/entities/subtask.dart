import 'package:freezed_annotation/freezed_annotation.dart';
import '../../core/database/tables.dart';

part 'subtask.freezed.dart';
part 'subtask.g.dart';

@freezed
class SubTask with _$SubTask {
  const factory SubTask({
    required String id,
    required String taskId,
    required String title,
    @Default(false) bool isCompleted,
    @Default(0) int orderIndex,
  }) = _SubTask;

  factory SubTask.fromJson(Map<String, dynamic> json) => _$SubTaskFromJson(json);

  factory SubTask.fromDatabase(drift.SubTask dbSubTask) {
    return SubTask(
      id: dbSubTask.id,
      taskId: dbSubTask.taskId,
      title: dbSubTask.title,
      isCompleted: dbSubTask.isCompleted,
      orderIndex: dbSubTask.orderIndex,
    );
  }
}
