import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'task_dao.g.dart';

@DriftAccessor(tables: [Tasks, SubTasks])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.db);

  // Get all tasks
  Stream<List<Task>> watchAllTasks() {
    return select(tasks).watch();
  }

  Future<List<Task>> getAllTasks() {
    return select(tasks).get();
  }

  // Get active (non-completed) tasks
  Stream<List<Task>> watchActiveTasks() {
    return (select(tasks)
          ..where((t) => t.isCompleted.equals(false)))
        .watch();
  }

  // Get completed tasks
  Stream<List<Task>> watchCompletedTasks() {
    return (select(tasks)
          ..where((t) => t.isCompleted.equals(true))
          ..orderBy([
            (t) => OrderingTerm(
                  expression: t.completedAt,
                  mode: OrderingMode.desc,
                ),
          ]))
        .watch();
  }

  Future<List<Task>> getCompletedTasks() {
    return (select(tasks)
          ..where((t) => t.isCompleted.equals(true))
          ..orderBy([
            (t) => OrderingTerm(
                  expression: t.completedAt,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();
  }

  // Get tasks for today
  Stream<List<Task>> watchTodayTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return (select(tasks)
          ..where((t) => t.isCompleted.equals(false))
          ..where((t) => t.dueDate.isNotNull())
          ..where((t) => t.dueDate.isBetweenValues(
                today.millisecondsSinceEpoch,
                tomorrow.millisecondsSinceEpoch - 1,
              )))
        .watch();
  }

  // Get upcoming tasks
  Stream<List<Task>> watchUpcomingTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return (select(tasks)
          ..where((t) => t.isCompleted.equals(false))
          ..where((t) => t.dueDate.isNotNull())
          ..where((t) => t.dueDate.isBiggerOrEqual(
                Constant(tomorrow.millisecondsSinceEpoch),
              ))
          ..orderBy([
            (t) => OrderingTerm(expression: t.dueDate, mode: OrderingMode.asc),
          ]))
        .watch();
  }

  // Get tasks without due date
  Stream<List<Task>> watchNoDateTasks() {
    return (select(tasks)
          ..where((t) => t.isCompleted.equals(false))
          ..where((t) => t.dueDate.isNull()))
        .watch();
  }

  // Get tasks for a specific date
  Future<List<Task>> getTasksForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (select(tasks)
          ..where((t) => t.isCompleted.equals(false))
          ..where((t) => t.dueDate.isNotNull())
          ..where((t) => t.dueDate.isBetweenValues(
                startOfDay.millisecondsSinceEpoch,
                endOfDay.millisecondsSinceEpoch - 1,
              )))
        .get();
  }

  // Get single task
  Future<Task?> getTask(String id) {
    return (select(tasks)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  // Insert task
  Future<void> insertTask(TasksCompanion task) {
    return into(tasks).insert(task, mode: InsertMode.insertOrReplace);
  }

  // Update task
  Future<bool> updateTask(TasksCompanion task) {
    return update(tasks).replace(task);
  }

  // Delete task
  Future<int> deleteTask(String id) {
    return (delete(tasks)..where((t) => t.id.equals(id))).go();
  }

  // Mark task as completed
  Future<int> completeTask(String id) {
    return update(tasks).write(
      TasksCompanion(
        isCompleted: const Value(true),
        completedAt: Value(DateTime.now()),
      ),
    );
  }

  // Mark task as incomplete
  Future<int> uncompleteTask(String id) {
    return update(tasks).write(
      const TasksCompanion(
        isCompleted: Value(false),
        completedAt: Value.absent(),
      ),
    );
  }

  // Clear all completed tasks
  Future<int> clearCompletedTasks() {
    return (delete(tasks)..where((t) => t.isCompleted.equals(true))).go();
  }

  // Get total task count (for progress)
  Future<int> getTotalParentTaskCount() {
    return select(tasks).get().then((list) => list.length);
  }

  Future<int> getCompletedParentTaskCount() {
    return (select(tasks)
          ..where((t) => t.isCompleted.equals(true)))
        .get()
        .then((list) => list.length);
  }

  // Get task count for progress bar (parent tasks only)
  Stream<TaskProgress> watchTaskProgress() {
    return select(tasks).watch().asyncMap((total) async {
      final completed = await (select(tasks)
            ..where((t) => t.isCompleted.equals(true)))
          .get();
      return TaskProgress(
        completed: completed.length,
        total: total.length,
      );
    });
  }
}

class TaskProgress {
  final int completed;
  final int total;

  TaskProgress({required this.completed, required this.total});

  double get percentage => total > 0 ? completed / total : 0.0;
}
