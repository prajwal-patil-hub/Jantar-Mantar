import 'package:drift/drift.dart';

import '../domain/enums.dart';

/// Canonical public-layer facilities (server-verified; local cache).
@DataClassName('Facility')
class Facilities extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => textEnum<FacilityType>()();
  TextColumn get status => textEnum<FacilityStatus>()();
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  BoolColumn get canonical => boolean().withDefault(const Constant(true))();
  DateTimeColumn get verifiedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// "Water for ~200 people" readings with a TTL (30–60 min, server-set).
@DataClassName('CapacityReading')
class CapacityReadings extends Table {
  TextColumn get id => text()();
  TextColumn get facilityId => text().references(Facilities, #id)();
  TextColumn get resource => textEnum<ResourceType>()();
  IntColumn get forPeople => integer()();
  TextColumn get verifiedBy => text().nullable()();
  DateTimeColumn get verifiedAt => dateTime().nullable()();
  DateTimeColumn get expiresAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// User submissions. Append-only from the client's perspective; state moves
/// pending → approved/rejected only via server verdicts pulled during sync.
@DataClassName('Submission')
class Submissions extends Table {
  TextColumn get id => text()();
  TextColumn get facilityId => text().nullable()();
  RealColumn get lat => real().nullable()();
  RealColumn get lng => real().nullable()();

  /// JSON payload: category, capacity, status, note… Schema is validated
  /// server-side (SECURITY.md) — the client never trusts itself either.
  TextColumn get payload => text()();
  TextColumn get photoPath => text().nullable()();
  TextColumn get state => textEnum<SubmissionState>()();
  TextColumn get rejectReason => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('Alert')
class Alerts extends Table {
  TextColumn get id => text()();
  TextColumn get severity => textEnum<AlertSeverity>()();
  TextColumn get body => text()();
  RealColumn get lat => real().nullable()();
  RealColumn get lng => real().nullable()();
  RealColumn get radiusMeters => real().nullable()();
  TextColumn get createdBy => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get expiresAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Client-side outbox: every write lands here in the same transaction as its
/// local effect, and the sync worker drains it with exponential backoff.
@DataClassName('SyncQueueEntry')
class SyncQueueEntries extends Table {
  IntColumn get localId => integer().autoIncrement()();
  TextColumn get op => textEnum<SyncOp>()();
  TextColumn get entity => text()();
  TextColumn get entityId => text()();
  TextColumn get payload => text()();
  TextColumn get state =>
      textEnum<SyncState>().withDefault(Constant(SyncState.pending.name))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextAttemptAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
}
