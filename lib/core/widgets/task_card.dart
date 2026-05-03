import 'package:flutter/material.dart';
import '../../domain/entities/task.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';
import 'priority_indicator.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onCompleteChanged;
  final bool isCompleted;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onCompleteChanged,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppTheme.cardAnimation,
      curve: AppTheme.defaultCurve,
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox
                AnimatedSwitcher(
                  duration: AppTheme.shortAnimation,
                  child: Checkbox(
                    key: ValueKey(task.isCompleted),
                    value: task.isCompleted,
                    onChanged: onCompleteChanged != null
                        ? (value) => onCompleteChanged!(value ?? false)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: task.isCompleted
                              ? AppColors.textDisabled
                              : AppColors.textPrimary,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (task.description != null && task.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description!,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          PriorityIndicator(
                            priority: task.priority,
                            showLabel: true,
                          ),
                          if (task.formattedDueDate.isNotEmpty) ...[
                            const SizedBox(width: 16),
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: task.isOverdue && !task.isCompleted
                                  ? AppColors.priorityHigh
                                  : AppColors.textDisabled,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              task.formattedDueDate,
                              style: TextStyle(
                                fontSize: 12,
                                color: task.isOverdue && !task.isCompleted
                                    ? AppColors.priorityHigh
                                    : AppColors.textDisabled,
                              ),
                            ),
                          ],
                          if (task.isRepeating) ...[
                            const SizedBox(width: 12),
                            Icon(
                              Icons.repeat,
                              size: 14,
                              color: AppColors.accent.withOpacity(0.7),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedTaskCard extends StatefulWidget {
  final Task task;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onCompleteChanged;
  final int index;

  const AnimatedTaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onCompleteChanged,
    required this.index,
  });

  @override
  State<AnimatedTaskCard> createState() => _AnimatedTaskCardState();
}

class _AnimatedTaskCardState extends State<AnimatedTaskCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppTheme.cardAnimation,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: AppTheme.enterCurve),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: AppTheme.enterCurve),
    );

    // Staggered delay
    Future.delayed(
      Duration(milliseconds: widget.index * AppTheme.animStagger.inMilliseconds),
      () {
        if (mounted) _controller.forward();
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: TaskCard(
          task: widget.task,
          onTap: widget.onTap,
          onCompleteChanged: widget.onCompleteChanged,
        ),
      ),
    );
  }
}
