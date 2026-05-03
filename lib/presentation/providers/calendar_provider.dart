import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import 'task_repository_provider.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final calendarTasksProvider = FutureProvider.family<List<Task>, DateTime>((ref, date) async {
  final repo = ref.watch(taskRepositoryProvider);
  return await repo.getTasksForDate(date);
});

final allActiveTasksForCalendarProvider = StreamProvider<List<Task>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchActiveTasks();
});
