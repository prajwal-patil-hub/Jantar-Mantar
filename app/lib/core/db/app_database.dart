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
    RouteReports,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // v2: offline group-chat cache (ciphertext only). createTable does NOT
      // create the table's index — without this the chat query falls back to
      // a full scan on every poll, on exactly the low-end devices we target.
      if (from < 2) {
        await m.createTable(cachedGroupMessages);
        await m.create(idxCachedGroupMessagesGroup);
      }
      // v3: group-key epoch, so rotated keys can still decrypt old history.
      if (from == 2) {
        await m.addColumn(cachedGroupMessages, cachedGroupMessages.keyEpoch);
      }
      // v4: route reports (ADR-31). Same lesson as v2 — createTable does not
      // create the index, and the expiry sweep runs on every map read.
      if (from < 4) {
        await m.createTable(routeReports);
        await m.create(idxRouteReportsExpiry);
      }
    },
  );
}
