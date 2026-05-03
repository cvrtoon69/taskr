import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables.dart';
import 'daos/task_dao.dart';
import 'daos/subtask_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Tasks, SubTasks],
  daos: [TaskDao, SubTaskDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Handle future migrations here
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'taskr_database',
      native: const DriftNativeOptions(
        databasePath: 'taskr.sqlite',
      ),
    );
  }

  Future<void> closeDatabase() async {
    await close();
  }
}
