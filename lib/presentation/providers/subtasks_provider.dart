import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/subtask.dart';
import '../../domain/repositories/task_repository.dart';
import 'task_repository_provider.dart';

final subTasksProvider = StreamProvider.family<List<SubTask>, String>((ref, taskId) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchSubTasksForTask(taskId);
});
