# PROGRESS.md — Build Log
_Newest entry first. One entry per working session._

---
## Session 6 — 2026-07-24 · Phase 1: E4 facility detail + submit flow
**Done:**
- **Facility detail sheet** (`features/map/presentation/facility_detail_sheet.dart`, replaces peek): status pill, capacity numerals per resource with TTL degrade ("expired — needs re-check"), FreshnessBadge, stale banner, actions: Update this (prefilled flow) · Report closed (confirm → queued update submission) · Directions/Share stubs
- **5-step submit flow** (`features/submit/`): category icon grid (auto-advance) → location via drag mini-map starting at MAP CENTER (no GPS/permission; duplicate hint when same-type facility ≤60 m suggests "update instead") → capacity steppers + presets + skip → status segmented + note (photo tile disabled pending EXIF-strip pipeline) → review → submit = pending row + outbox entry in one transaction, snackbar "Saved — will send when connection returns"
- **Optimistic pending pins**: grey `PendingMarker` with schedule-send badge for own new-facility submissions (updates don't double-pin); Profile shows pending-uploads count badge
- Dev seed now includes capacity readings (one live, one expired for the TTL demo)
- Tests 22 green (submit walkthrough writes correct payload/outbox; prefilled update tags facilityId + mode=update; detail sheet TTL degrade + stale banner; report-closed queues submission)

**Lesson:** after `PageController.animateToPage` in widget tests, pump once to start the ticker, then pump(duration) — a single pump(duration) leaves the animation at progress 0.

**Next session:**
1. E5 verification queue + audit log — FIRST real backend work: create Supabase project, `supabase/` folder with initial migrations (tables per ARCHITECTURE.md + RLS deny-by-default + negative tests), swap `UnconfiguredRemoteApi` for the Supabase client, then admin queue UI
2. Alternative if backend deferred: E6 alerts feed + E7 SOS (both local-first buildable)
---
## Session 5 — 2026-07-24 · Phase 1: E3 map complete
**Done:**
- **ADR-13** (user approved recommendations): glass docked M3 nav bar · standard OSM tiles for MVP · icon deferred to Phase 2
- E3 complete (`app/lib/features/map/`, `app/lib/core/map/`, `app/lib/core/widgets/`):
  - flutter_map 8.3 + FMTC 10.1 offline tile cache (ObjectBox); `main()` falls back to network tiles if FMTC can't start — app never blocks on infra; OSM attribution widget; `mapTileProviderProvider` swappable (tests use a stub)
  - Clustered pins (flutter_map_marker_cluster): FacilityMarker = type icon + status-colored border + status glyph badge + Semantics label (color+icon+text rule)
  - Filter chips (All + 7 types) → `mapFilterProvider` → Drift-stream-backed `facilitiesProvider`
  - FreshnessBadge (fresh/judgment/stale bands with color+icon+text); Nearby draggable glass sheet sorted by distance from MAP CENTER (no GPS = no permission needed to browse); pin-tap peek sheet (full detail is E4)
  - GlassSurface hero-surface widget with opaque fallback (weak device/high-contrast); `glassEnabledProvider` static true until Phase 2 probe; glass nav bar in HomeShell (extendBody)
  - Recenter FAB, Report FAB (E4 placeholder), 60dp SOS element (E7 placeholder)
  - Debug-only seed facilities around Jantar Mantar (`core/db/dev_seed.dart`, kDebugMode only)
- Tests 18 green (map: filter narrowing, nearby distance sort, full map-screen widget test incl. filter interaction)

**Broke/blocked (lessons):**
- Riverpod 3: `container.read(provider.future)` alone never resolves a StreamProvider — need an active `container.listen` first
- Drift stream teardown schedules a zero-duration timer → widget tests must end with `pumpWidget(SizedBox())` + a flush pump or fake-async flags a pending timer
- `pumpAndSettle` hangs (10-min default timeout) with the map mounted — use bounded pumps

**Next session:**
1. E4: facility detail sheet (capacity numerals, photos, actions) + 5-step submit flow wired to SubmissionRepository (offline-queued, optimistic grey "Pending (yours)" pin)
2. Later: connectivity/freshness banner (needs connectivity_plus + sync scheduling), region bulk-download at onboarding
---
## Session 4 — 2026-07-24 · Phase 1: E2 offline data layer + app named CommonGround
**Done:**
- **ADR-12: app name = CommonGround** (user decision) — applied to Android label, iOS CFBundleDisplayName/CFBundleName, web manifest (+ saffron theme_color) and index.html, MaterialApp title. Package name unchanged.
- E2 complete:
  - Domain: enums (FacilityType/Status, ResourceType, AlertSeverity, SubmissionState, SyncState/Op), freshness banding helper (<5m/5–30m/>30m)
  - Drift schema v1 (`core/db/`): Facilities, CapacityReadings (TTL), Submissions (JSON payload, pending→approved/rejected), Alerts, SyncQueueEntries (outbox: attempts, nextAttemptAt)
  - Repositories (`core/data/`): FacilityRepository (stream reads, upsert for future remote refresh), SubmissionRepository (submit = pending row + outbox entry in ONE transaction), AlertRepository (active alerts, critical ranked first)
  - SyncWorker: drains outbox oldest-first, exponential backoff 2s·2^n capped 10min, maxAttempts=12 → `failed` state, `retryFailed()` for the pending-uploads tray; `RemoteSyncApi` interface with `UnconfiguredRemoteApi` stub until Supabase client (E5/E8)
  - Riverpod providers (`core/providers.dart`); drift_flutter DB file `commonground`
- Tests: 15 green (freshness bands, atomic submit+outbox, pending count, backoff schedule, max-attempts terminal state, manual retry, repo filters/ordering, alert expiry+severity ranking)
- `flutter analyze` + `dart run custom_lint` clean

**Decisions this session:** ADR-12 (CommonGround)

**Broke/blocked:** E3 blocked on DESIGN.md open choices 3b/4/5 (icon, nav bar treatment, tile style) — ask user, don't assume.

**Next session:**
1. Ask user: icon direction, nav bar (glass pill vs docked), tile style → then E3 map (flutter_map + OSM + FMTC, clustered pins, filter chips, freshness banding UI)
2. Consider wiring pending-uploads count badge into Profile placeholder
3. Sync scheduling (connectivity listener + periodic drain) when first remote lands
---
## Session 3 — 2026-07-24 · Phase 0: E1 complete (backend confirmed, Flutter scaffold, lints, CI)
**Done:**
- Docs imported to GitHub repo (`prajwal-patil-hub/Jantar-Mantar`), monorepo layout locked (ADR-11): docs at root, app in `app/`
- **ADR-8 CONFIRMED: Supabase** (user decision) — Postgres RLS deny-by-default, anon auth, Mumbai region, self-host escape hatch
- **ADR-10: accent = Saffron `#FF6D1F`** (user decision, trade-offs flagged) + **dark mode = system-follow**; mitigation: accent never conveys status (`StatusColors` ThemeExtension holds semantic colors outside seed scheme)
- Flutter 3.44.8 scaffold in `app/` (android/ios/web), package `jantar_mantar_sahayata`, Riverpod 3.1 (+ riverpod_annotation/generator/lint, build_runner, custom_lint)
- Feature-first structure: `lib/core/theme/` (tokens, StatusColors extension, light/dark themes) + `lib/features/{shell,map,events,alerts,profile}/`; 4-destination NavigationBar shell with placeholder screens
- Strict `analysis_options.yaml` (strict casts/inference/raw-types + extra lint rules); `flutter analyze`, `dart run custom_lint`, `flutter test` all green (2 widget tests)
- CI: `.github/workflows/ci.yml` — format check, analyze, custom_lint, test (working-directory `app/`)
- SECURITY: `android:usesCleartextTraffic="false"` set (iOS ATS default-on, no exceptions added)

**Decisions this session:** ADR-8 confirmed · ADR-10 · ADR-11

**Broke/blocked:** container has no Android SDK/emulator — "boots on emulator" exit criterion needs CI APK build or user's machine. Android `applicationId` still `com.example.*` (decide before release).

**Next session:**
1. E2 offline data layer: Drift schema (Facility, Submission, CapacityReading, Alert, SyncQueue) + repository pattern
2. Ask user: DESIGN.md open choices 3–5 (app name/icon, nav bar treatment, tile style) before E3 map
3. Consider CI job that builds a debug APK as the "boots" proxy
---
## Session 2 — 2026-07-24 · Phase 0: Design direction + Claude Code handoff
**Done:**
- UI direction locked (ADR-9): glassmorphism (hero surfaces + fallback), neutral + one accent, rich animations → DESIGN.md created
- CLAUDE.md created for Claude Code sessions; research reports archived under docs/research/
- Full package zipped for repo import

**Decisions this session:** ADR-9 (UI). ADR-8 (Supabase) STILL PENDING confirmation.

**Next session (in Claude Code):**
1. Confirm ADR-8 backend → 2. `flutter create` + feature-first structure + Riverpod → 3. lints, git, CI
4. Answer DESIGN.md §Open choices (accent color, dark default, nav style, tile style, app name/icon)
---
## Session 1 — 2026-07-24 · Phase 0: Foundation
**Done:**
- Created doc system: README, CONTEXT, PROJECT_MANAGEMENT, ARCHITECTURE, SECURITY, DECISIONS, progress/
- Locked ADR-1…7; ADR-8 (Supabase) proposed
- Architecture diagram drafted (see ARCHITECTURE.md + architecture.mermaid)

**Decisions this session:** doc-driven workflow; MVP scope frozen (no groups until Phase 3)

**Broke/blocked:** —

**Next session:**
1. Confirm ADR-8 (Supabase vs Firebase)
2. `flutter create jantar_mantar_sahayata` + feature-first folder structure
3. Add lints, git init, first commit

**Note:** This workspace resets between sessions — keep these files in your own git repo
(e.g., GitHub private repo) and re-upload/point me at it each session.
---
