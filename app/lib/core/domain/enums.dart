/// Domain enums mirroring the ARCHITECTURE.md data model. Stored as text in
/// Drift (and later in Postgres) — never reorder-sensitive integers.
library;

/// Facility categories from the submit flow (ui-ux-spec §1.8).
enum FacilityType { water, food, shelter, medical, toilet, safeArea, danger }

enum FacilityStatus { good, low, out, closed }

/// Resources a capacity reading can describe.
enum ResourceType { water, food, shelter }

enum AlertSeverity { info, warn, critical }

enum SubmissionState { pending, approved, rejected }

/// Client-side sync queue lifecycle. `failed` is terminal (max attempts
/// exhausted) and surfaces in the pending-uploads tray for manual retry.
enum SyncState { pending, done, failed }

enum SyncOp { create, update, delete }
