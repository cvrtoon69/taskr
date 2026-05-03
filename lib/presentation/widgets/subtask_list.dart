import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/subtask.dart';
import '../providers/task_repository_provider.dart';

class SubTaskList extends ConsumerWidget {
  final String taskId;
  final bool canEdit;

  const SubTaskList({
    super.key,
    required this.taskId,
    this.canEdit = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subTasksAsync = ref.watch(subTasksProvider(taskId));

    return subTasksAsync.when(
      data: (subTasks) {
        if (subTasks.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: subTasks.map((subTask) {
            return _SubTaskItem(
              subTask: subTask,
              onToggle: canEdit
                  ? (completed) => _toggleSubTask(ref, subTask, completed)
                  : null,
            );
          }).toList(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Future<void> _toggleSubTask(
    WidgetRef ref,
    SubTask subTask,
    bool completed,
  ) async {
    final repo = ref.read(taskRepositoryProvider);
    await repo.toggleSubTaskCompletion(subTask.id, completed);
  }
}

class _SubTaskItem extends StatelessWidget {
  final SubTask subTask;
  final ValueChanged<bool>? onToggle;

  const _SubTaskItem({
    required this.subTask,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: subTask.isCompleted,
              onChanged: onToggle != null
                  ? (value) => onToggle!(value ?? false)
                  : null,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              subTask.title,
              style: TextStyle(
                fontSize: 14,
                color: subTask.isCompleted
                    ? AppColors.textDisabled
                    : AppColors.textSecondary,
                decoration: subTask.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
