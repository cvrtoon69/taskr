import 'package:drift/drift.dart';

enum Priority { low, medium, high }

enum RepeatType { daily, weekly, monthly }

@DataClassName('Task')
class Tasks extends Table {
  TextColumn get id => text().withLength(min: 1, max: 50)();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable().withLength(max: 1000)();
  IntColumn get dueDate => integer().nullable()();
  IntColumn get dueTime => integer().nullable()();
  IntColumn get priority => intEnum<Priority>()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isRepeating => boolean().withDefault(const Constant(false))();
  IntColumn get repeatType => intEnum<RepeatType>().nullable()();
  BoolColumn get reminderEnabled => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SubTask')
class SubTasks extends Table {
  TextColumn get id => text().withLength(min: 1, max: 50)();
  TextColumn get taskId => text().withLength(min: 1, max: 50)();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
