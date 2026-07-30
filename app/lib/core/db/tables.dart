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

/// Local cache of group chat so conversations open instantly and stay readable
/// with no network.
///
/// Deliberately stores **ciphertext only** — never plaintext. The group key
/// lives in the OS keystore, so a seized device with a dumped SQLite file
/// yields nothing, and panic-wiping the keys makes this table unreadable
/// (SECURITY.md: "minimal local sensitive data"). Rows with [pending] set are
/// outgoing messages encrypted on-device but not yet accepted by the server.
@DataClassName('CachedGroupMessage')
@TableIndex(name: 'idx_cached_group_messages_group', columns: {#groupId})
class CachedGroupMessages extends Table {
  /// Server message id once acknowledged; a `local:` id while pending.
  TextColumn get id => text()();
  TextColumn get groupId => text()();
  TextColumn get senderId => text()();
  TextColumn get ciphertext => text()();

  /// Which group-key epoch this ciphertext was sealed under. Keys rotate when
  /// a member is removed, and old keys are kept so history stays readable.
  IntColumn get keyEpoch => integer().withDefault(const Constant(1))();
  BoolColumn get pending => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

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

/// A stretch of route reported as impassable or hard to pass (ADR-31).
///
/// The map has always held *points*; a disaster needs *edges*. The case that
/// forced this: during the June 2026 Venezuela earthquakes an aftershock
/// collapsed a bridge and cut a whole parish off mid-response. A facility pin
/// cannot express "the way there is gone".
///
/// Modelled as a single segment (two endpoints) rather than a polyline or a
/// routable graph: enough to draw "do not go along here", small enough to
/// sync over a bad link, and simple enough to place with two drags.
///
/// [expiresAt] is **not nullable on purpose**. A stale blockage is not a
/// harmless leftover — it diverts people away from what may be the only
/// viable road, so every report has to age out and be re-asserted.
@DataClassName('RouteReport')
@TableIndex(name: 'idx_route_reports_expiry', columns: {#expiresAt})
class RouteReports extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get condition => textEnum<RouteCondition>()();
  TextColumn get cause => textEnum<RouteCause>()();
  RealColumn get startLat => real()();
  RealColumn get startLng => real()();
  RealColumn get endLat => real()();
  RealColumn get endLng => real()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get verifiedAt => dateTime().nullable()();
  DateTimeColumn get expiresAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
