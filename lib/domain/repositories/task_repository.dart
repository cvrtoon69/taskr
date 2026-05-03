import '../entities/task.dart';
import '../entities/subtask.dart';

abstract class TaskRepository {
  // Tasks
  Stream<List<Task>> watchAllTasks();
  Stream<List<Task>> watchActiveTasks();
  Stream<List<Task>> watchCompletedTasks();
  Stream<List<Task>> watchTodayTasks();
  Stream<List<Task>> watchUpcomingTasks();
  Stream<List<Task>> watchNoDateTasks();
  Future<List<Task>> getTasksForDate(DateTime date);
  Future<Task?> getTask(String id);
  
  Future<void> addTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String id);
  
  Future<void> completeTask(String id);
  Future<void> uncompleteTask(String id);
  Future<Task?> completeTaskWithRepeat(String id);
  
  Future<void> clearCompletedTasks();
  
  Stream<TaskProgress> watchTaskProgress();
  
  // SubTasks
  Stream<List<SubTask>> watchSubTasksForTask(String taskId);
  Future<List<SubTask>> getSubTasksForTask(String taskId);
  Future<void> addSubTask(SubTask subTask);
  Future<void> updateSubTask(SubTask subTask);
  Future<void> deleteSubTask(String id);
  Future<void> toggleSubTaskCompletion(String id, bool isCompleted);
}

class TaskProgress {
  final int completed;
  final int total;

  TaskProgress({required this.completed, required this.total});

  double get percentage => total > 0 ? completed / total : 0.0;
}
