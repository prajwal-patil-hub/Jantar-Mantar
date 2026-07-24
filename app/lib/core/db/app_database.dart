import 'package:drift/drift.dart';

import '../domain/enums.dart';
import 'tables.dart';

export '../domain/enums.dart';
export 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Facilities, CapacityReadings, Submissions, Alerts, SyncQueueEntries],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
