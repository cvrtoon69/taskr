import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import 'task_repository_provider.dart';

// All active tasks
final allTasksProvider = StreamProvider<List<Task>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchActiveTasks();
});

// Today's tasks
final todayTasksProvider = StreamProvider<List<Task>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchTodayTasks();
});

// Upcoming tasks
final upcomingTasksProvider = StreamProvider<List<Task>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchUpcomingTasks();
});

// Tasks without date
final noDateTasksProvider = StreamProvider<List<Task>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchNoDateTasks();
});

// Completed tasks
final completedTasksProvider = StreamProvider<List<Task>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchCompletedTasks();
});

// Task progress
final taskProgressProvider = StreamProvider<TaskProgress>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchTaskProgress();
});

// Filter state
enum TaskFilter { all, today, upcoming }

final taskFilterProvider = StateProvider<TaskFilter>((ref) => TaskFilter.all);

// Filtered tasks based on selected filter
final filteredTasksProvider = Provider<AsyncValue<List<Task>>>((ref) {
  final filter = ref.watch(taskFilterProvider);
  final allTasks = ref.watch(allTasksProvider);
  final todayTasks = ref.watch(todayTasksProvider);
  final upcomingTasks = ref.watch(upcomingTasksProvider);
  final noDateTasks = ref.watch(noDateTasksProvider);

  switch (filter) {
    case TaskFilter.all:
      // Combine all active tasks
      return allTasks.when(
        data: (tasks) => AsyncValue.data(tasks),
        loading: () => const AsyncValue.loading(),
        error: (err, stack) => AsyncValue.error(err, stack),
      );
    case TaskFilter.today:
      return todayTasks.when(
        data: (tasks) => AsyncValue.data(tasks),
        loading: () => const AsyncValue.loading(),
        error: (err, stack) => AsyncValue.error(err, stack),
      );
    case TaskFilter.upcoming:
      return upcomingTasks.when(
        data: (tasks) => AsyncValue.data(tasks),
        loading: () => const AsyncValue.loading(),
        error: (err, stack) => AsyncValue.error(err, stack),
      );
  }
});

// Current task being edited
final currentTaskProvider = StateProvider<Task?>((ref) => null);
