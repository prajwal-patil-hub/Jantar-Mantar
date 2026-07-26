import 'package:drift/drift.dart';

import '../domain/enums.dart';
import 'tables.dart';

export '../domain/enums.dart';
export 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Facilities,
    CapacityReadings,
    Submissions,
    Alerts,
    SyncQueueEntries,
    CachedGroupMessages,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // v2: offline group-chat cache (ciphertext only).
      if (from < 2) await m.createTable(cachedGroupMessages);
    },
  );
}
