import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_theme.dart';
import '../../core/services/haptic_service.dart';
import '../../core/widgets/animated_background.dart';
import '../../core/widgets/task_card.dart';
import '../../domain/entities/task.dart';
import '../providers/task_repository_provider.dart';
import '../providers/tasks_provider.dart';

class CompletedScreen extends ConsumerWidget {
  const CompletedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedTasksAsync = ref.watch(completedTasksProvider);

    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Completed'),
          actions: [
            TextButton(
              onPressed: () => _showClearConfirmation(context, ref),
              child: const Text(
                'Clear All',
                style: TextStyle(color: AppColors.accent),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: completedTasksAsync.when(
            data: (tasks) {
              if (tasks.isEmpty) {
                return _buildEmptyState();
              }

              final groupedTasks = _groupTasksByDate(tasks);

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: groupedTasks.length,
                itemBuilder: (context, index) {
                  final group = groupedTasks[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12, top: 8),
                        child: Text(
                          group.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                      ...group.tasks.map((task) => TaskCard(
                            task: task,
                            onCompleteChanged: (completed) =>
                                _onTaskUncomplete(ref, task, completed),
                          )),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
            error: (error, stack) => Center(
              child: Text(
                'Error loading tasks',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: AppColors.textDisabled.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No completed tasks',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete tasks to see them here',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textDisabled,
            ),
          ),
        ],
      ),
    );
  }

  List<TaskGroup> _groupTasksByDate(List<Task> tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final groups = <String, List<Task>>{};

    for (final task in tasks) {
      final completedAt = task.completedAt;
      if (completedAt == null) continue;

      String key;
      final completedDate = DateTime(
        completedAt.year,
        completedAt.month,
        completedAt.day,
      );

      if (completedDate == today) {
        key = 'Today';
      } else if (completedDate == yesterday) {
        key = 'Yesterday';
      } else {
        key = DateFormat('MMMM d, y').format(completedDate);
      }

      groups.putIfAbsent(key, () => []);
      groups[key]!.add(task);
    }

    return groups.entries
        .map((e) => TaskGroup(title: e.key, tasks: e.value))
        .toList();
  }

  Future<void> _onTaskUncomplete(WidgetRef ref, Task task, bool completed) async {
    if (!completed) {
      await HapticService().lightImpact();
      final repo = ref.read(taskRepositoryProvider);
      await repo.uncompleteTask(task.id);
    }
  }

  Future<void> _showClearConfirmation(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Clear Completed Tasks',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'This will permanently delete all completed tasks. Are you sure?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Clear',
              style: TextStyle(color: AppColors.priorityHigh),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await HapticService().confirm();
      final repo = ref.read(taskRepositoryProvider);
      await repo.clearCompletedTasks();
    }
  }
}

class TaskGroup {
  final String title;
  final List<Task> tasks;

  TaskGroup({required this.title, required this.tasks});
}
