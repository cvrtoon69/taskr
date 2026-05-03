import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'subtask_dao.g.dart';

@DriftAccessor(tables: [SubTasks])
class SubTaskDao extends DatabaseAccessor<AppDatabase> with _$SubTaskDaoMixin {
  SubTaskDao(super.db);

  // Get subtasks for a task
  Stream<List<SubTask>> watchSubTasksForTask(String taskId) {
    return (select(subTasks)
          ..where((st) => st.taskId.equals(taskId))
          ..orderBy([(st) => OrderingTerm(expression: st.orderIndex)]))
        .watch();
  }

  Future<List<SubTask>> getSubTasksForTask(String taskId) {
    return (select(subTasks)
          ..where((st) => st.taskId.equals(taskId))
          ..orderBy([(st) => OrderingTerm(expression: st.orderIndex)]))
        .get();
  }

  // Insert subtask
  Future<void> insertSubTask(SubTasksCompanion subTask) {
    return into(subTasks).insert(subTask);
  }

  // Update subtask
  Future<bool> updateSubTask(SubTasksCompanion subTask) {
    return update(subTasks).replace(subTask);
  }

  // Delete subtask
  Future<int> deleteSubTask(String id) {
    return (delete(subTasks)..where((st) => st.id.equals(id))).go();
  }

  // Delete all subtasks for a task
  Future<int> deleteSubTasksForTask(String taskId) {
    return (delete(subTasks)..where((st) => st.taskId.equals(taskId))).go();
  }

  // Toggle subtask completion
  Future<bool> toggleSubTaskCompletion(String id, bool isCompleted) {
    return (update(subTasks)..where((st) => st.id.equals(id))).write(
      SubTasksCompanion(isCompleted: Value(isCompleted)),
    );
  }

  // Mark all subtasks for a task as incomplete (for repeat)
  Future<int> resetSubTasksForTask(String taskId) {
    return (update(subTasks)..where((st) => st.taskId.equals(taskId))).write(
      const SubTasksCompanion(isCompleted: Value(false)),
    );
  }

  // Get next order index for a task
  Future<int> getNextOrderIndex(String taskId) async {
    final existing = await (select(subTasks)
          ..where((st) => st.taskId.equals(taskId)))
        .get();
    return existing.length;
  }
}
