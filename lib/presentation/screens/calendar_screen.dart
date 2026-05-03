import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_theme.dart';
import '../../core/services/haptic_service.dart';
import '../../core/widgets/animated_background.dart';
import '../../core/widgets/task_card.dart';
import '../../domain/entities/task.dart';
import '../providers/calendar_provider.dart';
import '../providers/task_repository_provider.dart';
import 'add_edit_task_screen.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final tasksAsync = ref.watch(calendarTasksProvider(selectedDate));
    final allTasksAsync = ref.watch(allActiveTasksForCalendarProvider);

    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Calendar'),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Calendar
              _buildCalendar(context, ref, selectedDate, allTasksAsync),
              const SizedBox(height: 8),
              // Task list for selected date
              Expanded(
                child: tasksAsync.when(
                  data: (tasks) {
                    if (tasks.isEmpty) {
                      return _buildEmptyState(context, selectedDate);
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return TaskCard(
                          task: task,
                          onTap: () => _onTaskTap(context, task),
                          onCompleteChanged: (completed) =>
                              _onTaskComplete(context, ref, task, completed),
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
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
    AsyncValue<List<Task>> allTasksAsync,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: allTasksAsync.when(
        data: (allTasks) {
          // Build event map
          final events = <DateTime, List<Task>>{};
          for (final task in allTasks) {
            if (task.dueDate != null) {
              final date = DateTime(
                task.dueDate!.year,
                task.dueDate!.month,
                task.dueDate!.day,
              );
              events.putIfAbsent(date, () => []);
              events[date]!.add(task);
            }
          }

          return TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: selectedDate,
            selectedDayPredicate: (day) => isSameDay(day, selectedDate),
            onDaySelected: (selected, focused) {
              HapticService().selectionClick();
              ref.read(selectedDateProvider.notifier).state = selected;
            },
            onDayLongPressed: (selected, focused) {
              HapticService().longPress();
              _onLongPressDate(context, selected);
            },
            eventLoader: (day) {
              final date = DateTime(day.year, day.month, day.day);
              return events[date] ?? [];
            },
            calendarStyle: CalendarStyle(
              defaultTextStyle: const TextStyle(color: AppColors.textPrimary),
              weekendTextStyle: TextStyle(color: AppColors.textSecondary),
              outsideTextStyle: TextStyle(color: AppColors.textDisabled.withOpacity(0.5)),
              todayDecoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              todayTextStyle: const TextStyle(color: AppColors.textPrimary),
              selectedDecoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(color: AppColors.textPrimary),
              markerDecoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,
              markerSize: 6,
            ),
            headerStyle: HeaderStyle(
              titleTextStyle: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
              formatButtonVisible: false,
              leftChevronIcon: const Icon(
                Icons.chevron_left,
                color: AppColors.textSecondary,
              ),
              rightChevronIcon: const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
              titleCentered: true,
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: AppColors.textSecondary),
              weekendStyle: TextStyle(color: AppColors.textDisabled),
            ),
          );
        },
        loading: () => const SizedBox(
          height: 300,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
        ),
        error: (_, __) => const SizedBox(
          height: 300,
          child: Center(
            child: Text(
              'Error loading calendar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, DateTime date) {
    final dateStr = DateFormat('MMMM d').format(date);
    final isToday = DateTime.now().year == date.year &&
        DateTime.now().month == date.month &&
        DateTime.now().day == date.day;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 64,
            color: AppColors.textDisabled.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            isToday ? 'No tasks for today' : 'No tasks for $dateStr',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Long-press a date to add a task',
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

  void _onLongPressDate(BuildContext context, DateTime date) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AddEditTaskScreen(initialDate: date),
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
}
