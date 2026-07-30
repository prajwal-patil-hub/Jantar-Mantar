/// Domain enums mirroring the ARCHITECTURE.md data model. Stored as text in
/// Drift (and later in Postgres) — never reorder-sensitive integers.
library;

/// Facility categories from the submit flow (ui-ux-spec §1.8).
enum FacilityType { water, food, shelter, medical, toilet, safeArea, danger }

enum FacilityStatus { good, low, out, closed }

/// Resources a capacity reading can describe.
enum ResourceType { water, food, shelter }

enum AlertSeverity { info, warn, critical }

/// Condition of a stretch of route (ADR-31).
///
/// There is deliberately **no `open` value**. Crowd data can report a hazard;
/// it cannot certify that a road is safe, and an app that says "open" to
/// someone deciding whether to drive through floodwater is making a
/// life-safety claim it has no basis for. [cleared] is the *retraction of a
/// previous report* — "this was reported blocked and is now passable" — not a
/// statement that an unreported road is fine.
enum RouteCondition { impassable, difficult, cleared }

/// Why a route is affected. Drives the icon and the wording; `blocked` covers
/// a closure by authorities, which reads very differently from a collapse.
enum RouteCause { flood, collapse, debris, blocked, other }

enum SubmissionState { pending, approved, rejected }

/// Client-side sync queue lifecycle. `failed` is terminal (max attempts
/// exhausted) and surfaces in the pending-uploads tray for manual retry.
enum SyncState { pending, done, failed }

enum SyncOp { create, update, delete }
