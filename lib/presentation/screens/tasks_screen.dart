import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_theme.dart';
import '../../core/services/haptic_service.dart';
import '../../core/widgets/animated_background.dart';
import '../../core/widgets/task_card.dart';
import '../../domain/entities/task.dart';
import '../providers/task_repository_provider.dart';
import '../providers/tasks_provider.dart';
import '../widgets/greeting_header.dart';
import '../widgets/progress_bar.dart';
import 'add_edit_task_screen.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(taskFilterProvider);
    final tasksAsync = ref.watch(filteredTasksProvider);

    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const GreetingHeader(),
                      const SizedBox(height: 20),
                      const TaskProgressBar(),
                      const SizedBox(height: 24),
                      _buildFilterChips(context, ref, filter),
                    ],
                  ),
                ),
              ),
              // Task list
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: tasksAsync.when(
                  data: (tasks) {
                    if (tasks.isEmpty) {
                      return SliverToBoxAdapter(
                        child: _buildEmptyState(context),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final task = tasks[index];
                          return AnimatedTaskCard(
                            key: ValueKey(task.id),
                            task: task,
                            index: index,
                            onTap: () => _onTaskTap(context, task),
                            onCompleteChanged: (completed) =>
                                _onTaskComplete(context, ref, task, completed),
                          );
                        },
                        childCount: tasks.length,
                      ),
                    );
                  },
                  loading: () => const SliverToBoxAdapter(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                  error: (error, stack) => SliverToBoxAdapter(
                    child: Center(
                      child: Text(
                        'Error loading tasks',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Bottom padding for FAB
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, WidgetRef ref, TaskFilter currentFilter) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: TaskFilter.values.map((filter) {
          final isSelected = filter == currentFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                filter.name.substring(0, 1).toUpperCase() +
                    filter.name.substring(1),
              ),
              selected: isSelected,
              onSelected: (_) {
                HapticService().selectionClick();
                ref.read(taskFilterProvider.notifier).state = filter;
              },
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.accent.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.accent : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.accent : Colors.transparent,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: AppColors.textDisabled.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first task',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textDisabled,
            ),
          ),
        ],
      ),
    );
  }

  void _onTaskTap(BuildContext context, Task task) {
    HapticService().lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AddEditTaskScreen(task: task),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: AppTheme.mediumAnimation,
      ),
    );
  }

  Future<void> _onTaskComplete(
    BuildContext context,
    WidgetRef ref,
    Task task,
    bool completed,
  ) async {
    if (completed) {
      await HapticService().confirm();
      final repo = ref.read(taskRepositoryProvider);
      await repo.completeTaskWithRepeat(task.id);
    } else {
      await HapticService().lightImpact();
      final repo = ref.read(taskRepositoryProvider);
      await repo.uncompleteTask(task.id);
    }
  }
}
