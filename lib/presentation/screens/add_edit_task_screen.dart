import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_theme.dart';
import '../../core/database/tables.dart';
import '../../core/services/haptic_service.dart';
import '../../core/widgets/animated_background.dart';
import '../../core/widgets/priority_indicator.dart';
import '../../domain/entities/subtask.dart';
import '../../domain/entities/task.dart';
import '../providers/subtasks_provider.dart';
import '../providers/task_repository_provider.dart';

class AddEditTaskScreen extends ConsumerStatefulWidget {
  final Task? task;
  final DateTime? initialDate;

  const AddEditTaskScreen({super.key, this.task, this.initialDate});

  @override
  ConsumerState<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends ConsumerState<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _uuid = const Uuid();

  late Priority _priority;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  bool _reminderEnabled = false;
  bool _isRepeating = false;
  RepeatType? _repeatType;

  final List<SubTask> _subTasks = [];
  final _subTaskController = TextEditingController();

  bool get _isEditing => widget.task != null;
  bool get _canSave => _titleController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _initializeFromTask();
  }

  void _initializeFromTask() {
    if (widget.task != null) {
      final task = widget.task!;
      _titleController.text = task.title;
      _descriptionController.text = task.description ?? '';
      _priority = task.priority;
      _dueDate = task.dueDate;
      _dueTime = task.dueTime != null
          ? TimeOfDay(hour: task.dueTime!.hour, minute: task.dueTime!.minute)
          : null;
      _reminderEnabled = task.reminderEnabled;
      _isRepeating = task.isRepeating;
      _repeatType = task.repeatType;
    } else {
      _priority = Priority.medium;
      _dueDate = widget.initialDate;
    }

    _titleController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subTaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(_isEditing ? 'Edit Task' : 'New Task'),
          actions: [
            AnimatedOpacity(
              opacity: _canSave ? 1.0 : 0.5,
              duration: AppTheme.shortAnimation,
              child: IconButton(
                icon: const Icon(Icons.check),
                onPressed: _canSave ? _saveTask : null,
              ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Title
              _buildSectionTitle('Task Title *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'What needs to be done?',
                  hintStyle: TextStyle(color: AppColors.textDisabled),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Description
              _buildSectionTitle('Description'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Add details (optional)',
                  hintStyle: TextStyle(color: AppColors.textDisabled),
                ),
                maxLines: 3,
                minLines: 2,
              ),
              const SizedBox(height: 24),

              // Priority
              _buildSectionTitle('Priority'),
              const SizedBox(height: 8),
              PrioritySelector(
                selectedPriority: _priority,
                onPriorityChanged: (priority) {
                  setState(() => _priority = priority);
                },
              ),
              const SizedBox(height: 24),

              // Due Date
              _buildSectionTitle('Due Date'),
              const SizedBox(height: 8),
              _buildDateTimeSection(),
              const SizedBox(height: 24),

              // Reminder
              if (_dueTime != null) ...[
                _buildSwitchTile(
                  title: 'Enable Reminder',
                  subtitle: 'Notify me at the due time',
                  value: _reminderEnabled,
                  onChanged: (value) {
                    setState(() => _reminderEnabled = value);
                  },
                ),
                const SizedBox(height: 24),
              ],

              // Repeat
              _buildSwitchTile(
                title: 'Repeat Task',
                subtitle: 'Automatically create new task on completion',
                value: _isRepeating,
                onChanged: (value) {
                  setState(() {
                    _isRepeating = value;
                    if (!value) _repeatType = null;
                  });
                },
              ),
              if (_isRepeating) ...[
                const SizedBox(height: 12),
                _buildRepeatOptions(),
              ],
              const SizedBox(height: 24),

              // Sub-tasks
              _buildSectionTitle('Sub-tasks'),
              const SizedBox(height: 8),
              _buildSubTasksSection(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.accent,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Row(
      children: [
        // Date picker
        Expanded(
          child: _buildDateTimeButton(
            icon: Icons.calendar_today,
            label: _dueDate != null
                ? DateFormat('MMM d, y').format(_dueDate!)
                : 'Select Date',
            onTap: _pickDate,
          ),
        ),
        const SizedBox(width: 12),
        // Time picker
        Expanded(
          child: _buildDateTimeButton(
            icon: Icons.access_time,
            label: _dueTime != null
                ? _dueTime!.format(context)
                : 'Select Time',
            onTap: _pickTime,
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isSet = label != 'Select Date' && label != 'Select Time';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          border: Border.all(
            color: isSet ? AppColors.accent : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSet ? AppColors.accent : AppColors.textDisabled,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSet ? AppColors.textPrimary : AppColors.textDisabled,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accent,
            activeTrackColor: AppColors.accent.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildRepeatOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Repeat Every',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: RepeatType.values.map((type) {
              final isSelected = _repeatType == type;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _repeatType = type);
                    },
                    child: AnimatedContainer(
                      duration: AppTheme.shortAnimation,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accent.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.divider,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          type.name.substring(0, 1).toUpperCase() +
                              type.name.substring(1),
                          style: TextStyle(
                            fontSize: 13,
                            color: isSelected
                                ? AppColors.accent
                                : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTasksSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Existing subtasks
          ..._subTasks.asMap().entries.map((entry) {
            final index = entry.key;
            final subTask = entry.value;
            return _buildSubTaskItem(subTask, index);
          }),
          
          // Add new subtask input
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _subTaskController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Add a sub-task',
                    hintStyle: TextStyle(color: AppColors.textDisabled),
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _addSubTask(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add, color: AppColors.accent),
                onPressed: _addSubTask,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubTaskItem(SubTask subTask, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Checkbox(
            value: subTask.isCompleted,
            onChanged: (value) {
              setState(() {
                _subTasks[index] = subTask.copyWith(
                  isCompleted: value ?? false,
                );
              });
            },
          ),
          Expanded(
            child: Text(
              subTask.title,
              style: TextStyle(
                color: subTask.isCompleted
                    ? AppColors.textDisabled
                    : AppColors.textPrimary,
                decoration: subTask.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            color: AppColors.textDisabled,
            onPressed: () {
              setState(() {
                _subTasks.removeAt(index);
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accent,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accent,
              surface: AppColors.surface,
            ),
            timePickerTheme: const TimePickerThemeData(
              backgroundColor: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _dueTime = picked);
    }
  }

  void _addSubTask() {
    final title = _subTaskController.text.trim();
    if (title.isEmpty) return;

    setState(() {
      _subTasks.add(
        SubTask(
          id: _uuid.v4(),
          taskId: _isEditing ? widget.task!.id : '',
          title: title,
          orderIndex: _subTasks.length,
        ),
      );
      _subTaskController.clear();
    });
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    await HapticService().confirm();

    final taskId = _isEditing ? widget.task!.id : _uuid.v4();

    final task = Task(
      id: taskId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      dueDate: _dueDate,
      dueTime: _dueTime != null && _dueDate != null
          ? DateTime(
              _dueDate!.year,
              _dueDate!.month,
              _dueDate!.day,
              _dueTime!.hour,
              _dueTime!.minute,
            )
          : null,
      priority: _priority,
      isCompleted: _isEditing ? widget.task!.isCompleted : false,
      isRepeating: _isRepeating,
      repeatType: _isRepeating ? _repeatType : null,
      reminderEnabled: _reminderEnabled && _dueTime != null,
      createdAt: _isEditing ? widget.task!.createdAt : DateTime.now(),
    );

    final repo = ref.read(taskRepositoryProvider);

    if (_isEditing) {
      await repo.updateTask(task);
    } else {
      await repo.addTask(task);
    }

    // Save subtasks
    if (_isEditing) {
      // Delete existing and add new
      final existingSubTasks = await repo.getSubTasksForTask(taskId);
      for (final st in existingSubTasks) {
        await repo.deleteSubTask(st.id);
      }
    }

    for (final subTask in _subTasks) {
      final newSubTask = subTask.copyWith(
        id: _uuid.v4(),
        taskId: taskId,
      );
      await repo.addSubTask(newSubTask);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
