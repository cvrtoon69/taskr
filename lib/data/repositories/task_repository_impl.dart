import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart' as db;
import '../../core/database/tables.dart';
import '../../core/services/notification_service.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/subtask.dart';
import '../../domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final db.AppDatabase _database;
  final NotificationService _notifications;
  final Uuid _uuid = const Uuid();

  TaskRepositoryImpl(this._database, this._notifications);

  @override
  Stream<List<Task>> watchAllTasks() {
    return _database.taskDao.watchAllTasks().map(
          (list) => list.map((t) => Task.fromDatabase(t)).toList(),
        );
  }

  @override
  Stream<List<Task>> watchActiveTasks() {
    return _database.taskDao.watchActiveTasks().map(
          (list) => list.map((t) => Task.fromDatabase(t)).toList(),
        );
  }

  @override
  Stream<List<Task>> watchCompletedTasks() {
    return _database.taskDao.watchCompletedTasks().map(
          (list) => list.map((t) => Task.fromDatabase(t)).toList(),
        );
  }

  @override
  Stream<List<Task>> watchTodayTasks() {
    return _database.taskDao.watchTodayTasks().map(
          (list) => list.map((t) => Task.fromDatabase(t)).toList(),
        );
  }

  @override
  Stream<List<Task>> watchUpcomingTasks() {
    return _database.taskDao.watchUpcomingTasks().map(
          (list) => list.map((t) => Task.fromDatabase(t)).toList(),
        );
  }

  @override
  Stream<List<Task>> watchNoDateTasks() {
    return _database.taskDao.watchNoDateTasks().map(
          (list) => list.map((t) => Task.fromDatabase(t)).toList(),
        );
  }

  @override
  Future<List<Task>> getTasksForDate(DateTime date) async {
    final tasks = await _database.taskDao.getTasksForDate(date);
    return tasks.map((t) => Task.fromDatabase(t)).toList();
  }

  @override
  Future<Task?> getTask(String id) async {
    final task = await _database.taskDao.getTask(id);
    return task != null ? Task.fromDatabase(task) : null;
  }

  @override
  Future<void> addTask(Task task) async {
    await _database.taskDao.insertTask(_toCompanion(task));
    await _scheduleNotification(task);
  }

  @override
  Future<void> updateTask(Task task) async {
    await _database.taskDao.updateTask(_toCompanion(task));
    await _cancelNotification(task.id);
    await _scheduleNotification(task);
  }

  @override
  Future<void> deleteTask(String id) async {
    await _cancelNotification(id);
    await _database.subTaskDao.deleteSubTasksForTask(id);
    await _database.taskDao.deleteTask(id);
  }

  @override
  Future<void> completeTask(String id) async {
    await _cancelNotification(id);
    await _database.taskDao.completeTask(id);
  }

  @override
  Future<void> uncompleteTask(String id) async {
    await _database.taskDao.uncompleteTask(id);
    final task = await getTask(id);
    if (task != null) {
      await _scheduleNotification(task);
    }
  }

  @override
  Future<Task?> completeTaskWithRepeat(String id) async {
    final task = await getTask(id);
    if (task == null) return null;

    await _cancelNotification(id);

    if (task.isRepeating && task.repeatType != null) {
      // Generate new task with advanced date
      final newDueDate = _calculateNextDueDate(task);
      final newTask = task.copyWith(
        id: _uuid.v4(),
        isCompleted: false,
        completedAt: null,
        dueDate: newDueDate,
      );

      // Mark current as completed
      await _database.taskDao.completeTask(id);

      // Insert new task
      await _database.taskDao.insertTask(_toCompanion(newTask));

      // Copy subtasks but reset them
      final subTasks = await getSubTasksForTask(id);
      for (final subTask in subTasks) {
        final newSubTask = SubTask(
          id: _uuid.v4(),
          taskId: newTask.id,
          title: subTask.title,
          isCompleted: false,
          orderIndex: subTask.orderIndex,
        );
        await _database.subTaskDao.insertSubTask(_toSubTaskCompanion(newSubTask));
      }

      await _scheduleNotification(newTask);
      return newTask;
    } else {
      await _database.taskDao.completeTask(id);
      return null;
    }
  }

  DateTime? _calculateNextDueDate(Task task) {
    if (task.dueDate == null || task.repeatType == null) return null;

    final currentDue = task.dueDate!;
    switch (task.repeatType!) {
      case RepeatType.daily:
        return currentDue.add(const Duration(days: 1));
      case RepeatType.weekly:
        return currentDue.add(const Duration(days: 7));
      case RepeatType.monthly:
        // Handle month boundary
        var newMonth = currentDue.month + 1;
        var newYear = currentDue.year;
        if (newMonth > 12) {
          newMonth = 1;
          newYear++;
        }
        // Handle different month lengths
        var newDay = currentDue.day;
        final lastDayOfMonth = DateTime(newYear, newMonth + 1, 0).day;
        if (newDay > lastDayOfMonth) {
          newDay = lastDayOfMonth;
        }
        return DateTime(newYear, newMonth, newDay);
    }
    return null;
  }

  @override
  Future<void> clearCompletedTasks() async {
    final completed = await _database.taskDao.getCompletedTasks();
    for (final task in completed) {
      await _cancelNotification(task.id);
      await _database.subTaskDao.deleteSubTasksForTask(task.id);
    }
    await _database.taskDao.clearCompletedTasks();
  }

  @override
  Stream<TaskProgress> watchTaskProgress() {
    return _database.taskDao.watchTaskProgress().map(
          (p) => TaskProgress(completed: p.completed, total: p.total),
        );
  }

  // SubTasks
  @override
  Stream<List<SubTask>> watchSubTasksForTask(String taskId) {
    return _database.subTaskDao.watchSubTasksForTask(taskId).map(
          (list) => list.map((st) => SubTask.fromDatabase(st)).toList(),
        );
  }

  @override
  Future<List<SubTask>> getSubTasksForTask(String taskId) async {
    final subTasks = await _database.subTaskDao.getSubTasksForTask(taskId);
    return subTasks.map((st) => SubTask.fromDatabase(st)).toList();
  }

  @override
  Future<void> addSubTask(SubTask subTask) async {
    await _database.subTaskDao.insertSubTask(_toSubTaskCompanion(subTask));
  }

  @override
  Future<void> updateSubTask(SubTask subTask) async {
    await _database.subTaskDao.updateSubTask(_toSubTaskCompanion(subTask));
  }

  @override
  Future<void> deleteSubTask(String id) async {
    await _database.subTaskDao.deleteSubTask(id);
  }

  @override
  Future<void> toggleSubTaskCompletion(String id, bool isCompleted) async {
    await _database.subTaskDao.toggleSubTaskCompletion(id, isCompleted);
  }

  // Helpers
  db.TasksCompanion _toCompanion(Task task) {
    return db.TasksCompanion(
      id: Value(task.id),
      title: Value(task.title),
      description: Value(task.description),
      dueDate: Value(task.dueDate?.millisecondsSinceEpoch),
      dueTime: Value(task.dueTime?.millisecondsSinceEpoch),
      priority: Value(task.priority),
      isCompleted: Value(task.isCompleted),
      isRepeating: Value(task.isRepeating),
      repeatType: Value(task.repeatType),
      reminderEnabled: Value(task.reminderEnabled),
      createdAt: task.createdAt != null ? Value(task.createdAt!) : const Value.absent(),
      completedAt: Value(task.completedAt),
    );
  }

  db.SubTasksCompanion _toSubTaskCompanion(SubTask subTask) {
    return db.SubTasksCompanion(
      id: Value(subTask.id),
      taskId: Value(subTask.taskId),
      title: Value(subTask.title),
      isCompleted: Value(subTask.isCompleted),
      orderIndex: Value(subTask.orderIndex),
    );
  }

  Future<void> _scheduleNotification(Task task) async {
    if (!task.reminderEnabled) return;
    final notificationDate = task.notificationDateTime;
    if (notificationDate == null) return;
    if (notificationDate.isBefore(DateTime.now())) return;

    await _notifications.scheduleNotification(
      id: task.id.hashCode,
      title: 'Task Reminder',
      body: task.title,
      scheduledDate: notificationDate,
    );
  }

  Future<void> _cancelNotification(String taskId) async {
    await _notifications.cancelNotification(taskId.hashCode);
  }
}
