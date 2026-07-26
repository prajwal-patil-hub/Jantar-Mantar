# PROGRESS.md — Build Log
_Newest entry first. One entry per working session._

## Session 12 — 2026-07-25 · QR invites, persisted Demo Mode, group RLS negative tests
**Done:**
- **QR invites**: `qr_flutter` (per ADR/"never qr_code_scanner") invite sheet — scannable QR on a white backing (readable in dark mode), copyable code, and an explicit "24h · 10 uses · admin approval still required" line, replacing the plain text dialog. Bilingual.
- **Demo Mode persists** across launches (SharedPreferences, failure-tolerant like the locale provider); restored in `HomeShell.initState`.
- **`supabase/tests/rls_groups_negative_test.sql`** — 12 pgTAP negative assertions for the group tables: an outsider cannot read hidden groups, messages, group-private pins, the roster, invite codes, or another member's sealed key; cannot post messages or plant pins; cannot self-approve from pending to active; and a pending member cannot read messages before approval. Closes the SECURITY.md "group scoping enforced with RLS + negative tests" gate at the code level.
- 51 tests green (adds 3 demo-mode persistence tests); analyze + custom_lint clean; web build green.

**Honest gaps:** QR *scanning* (`mobile_scanner`) still to do — needs a physical device, so joining is code-paste for now. The group RLS tests are written but not yet RUN (needs `supabase start && supabase test db` locally) or wired into CI.

**Next:** local message caching, key rotation on member removal, group broadcast, QR scanning on device, RLS tests in CI.
---
## Session 11 — 2026-07-25 · Demo Mode (ADR-18) + group map layer, picker, Events i18n
**Done:**
- **ADR-18: Demo Mode, default ON** — user could not enable Supabase anonymous sign-in (no dashboard access), leaving Groups unusable. Added `core/demo/demo_mode.dart` and a `GroupsRepo` interface implemented by both the real `GroupsRepository` (E2E) and a new in-memory `DemoGroupsRepository`. Sample data: 3 groups (admin + member roles), members incl. a pending join request, bilingual chat history, group amenities; send/approve/create all work in-session.
- Verification queue works in demo (sample pending submissions, working approve/reject); `canVerifyProvider` opens the admin screen without a login. Profile gained a Demo mode switch.
- **Group amenities on the main map** + layers toggle FAB (off by default; square accent pins deliberately distinct from round public-facility pins so private group pins are never mistaken for verified public ones).
- **Map picker for group amenities** — replaced the hardcoded site-centre coordinate with a drag-to-place screen (same no-GPS approach as the submit flow).
- **Events screen** rebuilt with real sample events AND localized (en+hi) — it had shipped English-only, breaking the locked bilingual rule.
- 48 tests green (6 demo/group tests incl. Groups tab rendering with no Supabase client, and the map-layer provider); analyze + custom_lint clean; web build green.

**Honest gaps:** demo data is in-memory (resets on reload); demo chat is not encrypted (nothing leaves the device — the E2E path is the Supabase one); Demo Mode isn't persisted across reloads yet.

**Next:** persist Demo Mode, local message caching, key rotation on member removal, QR invites, group broadcast, RLS negative tests for group tables.
---
## Session 10 — 2026-07-25 · Fixes + Phase 3 kickoff: Groups + E2E chat (ADR-16), no mesh (ADR-17)
**Done:**
- **Web run fix:** drift needs `web:` DriftWebOptions + `web/sqlite3.wasm` + `web/drift_worker.js` (version-matched) — fixed the "web parameter needs to be set" startup crash; `flutter build web` green.
- **Nearby sheet fix:** was un-draggable (flutter_map pan gestures vs sheet drag + glass nav bar overlapping the handle). Now a DraggableScrollableController with tap-to-expand header + snap + nav-bar clearance; map test asserts header count.
- **ADR-17: no in-app Bluetooth mesh chat** (user agreed) — research flags it broken/battery-heavy/"never for sensitive data" and it can't run on web.
- **ADR-16: Groups (Phase 3) + E2E chat**, sequenced crypto-first:
  - `core/crypto/`: `E2ECrypto` (X25519 identity, random group key, ECIES sealed-box key delivery, AES-GCM-256 messages), `DeviceIdentityService` (seed in OS keystore via flutter_secure_storage, `KeyStore` abstraction + in-memory for tests). 7 tests incl. non-recipient-can't-open, wrong-key-can't-decrypt, tamper-fails.
  - `supabase/migrations/20260725000002_groups.sql`: groups/members/key_envelopes/invites/group_pins/group_messages + RLS deny-by-default + `is_group_member`/`is_group_admin`/`resolve_invite`.
  - `features/groups/`: repository wiring crypto↔Supabase (create→seal-to-self, approve→seal-to-member, send→encrypt, read→decrypt), providers, UI (list, create, join-by-code, detail with E2E Chat/Members/Amenities tabs, admin invite + approval). Groups tab added to nav (now 5 destinations).
  - New l10n keys (en+hi) for all group strings.
- 42 tests green; analyze + custom_lint clean; web build green.

**Deps added:** cryptography, flutter_secure_storage.

**USER ACTIONS for groups to work live:** apply BOTH migrations (init + groups) in SQL editor; groups need sign-in (anonymous is fine) — the Groups tab shows a notice until backend + auth are live.

**Known gaps (logged in ADR-16 / board):** key rotation on member removal, local message caching (currently online fetch), group-pin map picker, QR invites, group broadcast + map-layer toggle, RLS negative tests for group tables.

**Next:** wire the above gaps; run the two-device E2E chat smoke test once backend is applied.
---
## Session 9 — 2026-07-24 · Phase 1: E9 — Hindi/English i18n + accessibility baseline (MVP core complete)
**Done:**
- **ADR-15: Flutter gen-l10n** — `l10n.yaml` + `lib/l10n/app_en.arb` / `app_hi.arb` (~110 keys each incl. plurals/placeholders), typed `AppL10n`. Every user-facing screen localized: nav shell, map (filters, Report, recenter, Nearby), facility detail sheet (capacity/freshness/stale/actions/report-closed dialog), 5-step submit flow, alerts feed + critical banner, SOS (instructions, call tiles, reset), profile, admin login, verification queue.
- **Fonts:** bundled Noto Sans + Noto Sans Devanagari (6 TTFs from Google Fonts gstatic, in `assets/fonts/`), Devanagari wired as `fontFamilyFallback` so Hindi renders proper matras/conjuncts. NOT google_fonts runtime fetch (offline-first).
- **Locale plumbing:** `core/l10n/locale_provider.dart` (SharedPreferences-persisted, defensive on failure, defaults to system); instant Language toggle (English/हिन्दी SegmentedButton) in Profile; MaterialApp wired with delegates + supportedLocales.
- **Refactor:** domain enum labels moved to context-based `core/l10n/l10n_labels.dart`; `*_visuals.dart` now icons/colors only (removed English `.label` getters to avoid extension-name collision). Status stays color+icon+**localized** text everywhere.
- Tests 35 green (added `localization_test.dart`: Hindi nav labels render Devanagari; en/hi resolve distinct strings). Shared `test/support/l10n_harness.dart` supplies delegates to widget tests building their own MaterialApp.
- analyze + custom_lint clean.

**Accessibility pass (baseline):** 48dp+ targets across buttons/tiles; Semantics on markers + SOS; color+icon+text rule holds in both languages; respects system text scale + locale. Full TalkBack/OEM + CVD-simulator sweep deferred to Phase 2 hardening.

**Lesson:** two extensions on the same enum can't both expose a member named `label` (ambiguous) — dropped the English getters and centralized localized labels.

**Next session:** device end-to-end smoke test (submit→approve→verified pin, toggle Hindi mid-flow), then Phase 2 hardening: cert pinning (dio + pin), flutter_secure_storage for the Supabase session, panic-wipe, RLS negative tests in CI, CVD/TalkBack audit; plus alert-broadcast admin UI and the EXIF-strip photo pipeline.
---
## Session 8 — 2026-07-24 · Phase 1: E5+E8 — Supabase backend, sync, anon auth, admin queue
**Done:**
- User created Supabase project (`orsqjucexvrefmexztay`, publishable key committed — public-by-design)
- **`supabase/` backend-as-code (ADR-14):** `migrations/20260724000001_init.sql` — facilities, capacity_readings, submissions (client_id unique for idempotent retries, facility_ref text), alerts, sos_signals, append-only audit_log; RLS deny-by-default (public reads facilities/capacity/alerts; users insert+read only their own submissions/SOS; admins via `is_admin()` from app_metadata); `approve_submission`/`reject_submission` SECURITY DEFINER RPCs (approve resolves facility_ref, upserts facility, adds capacity reading w/ TTL, audits); pgTAP negative tests in `tests/rls_negative_test.sql`; setup steps in `supabase/README.md`
- **App sync (E8):** `SupabaseConfig` (public constants), `SupabaseRemoteApi` (push; 23505 duplicate = already-synced success), `RemotePullService` (facilities/capacity/alerts + own submission verdicts back into local rows), `SyncService` (anon sign-in → drain outbox → pull, 60 s timer, starts in HomeShell, no-op with null client so all tests stay offline), providers swap `UnconfiguredRemoteApi` automatically when a client exists
- **E5 UI:** Profile → Volunteer/admin tile → email/password login (role-gated display; server re-checks) → verification queue: oldest-first pending cards (category, status, capacity, geo, note), Approve / Reject-with-reason (Duplicate/Can't verify/Stale/Inaccurate/Spam)
- Tests 33 green (row-mapping both directions, SOS/sos_signals mapping, null-client SyncService no-op)

**USER ACTIONS REQUIRED before live sync works:** (1) paste migration into SQL editor, (2) enable Anonymous sign-ins, (3) create admin user + grant role — exact steps in `supabase/README.md`.

**Next session:**
1. Smoke test on device: submit → queue → approve in admin → pull → verified pin appears
2. E9 i18n (en/hi) + accessibility pass, or hardening: cert pinning, flutter_secure_storage, RLS tests in CI, alert broadcast UI
---
## Session 7 — 2026-07-24 · Phase 1: E6 alerts feed + E7 SOS (user chose backend-later)
**Done:**
- Repo hygiene: confirmed the session branch never existed on the Spotify-extractor remote (stale local tracking ref only, pruned); all project work isolated to Jantar-Mantar repo
- **E6 (user side):** alerts feed (`features/alerts/`) — severity cards (info blue `#1976D2` distinct from status amber/red, icon+label+color always together), critical-first ordering, relative timestamps, "Verified by admin" note, offline "may be outdated" footer; `CriticalAlertBanner` on the map: full-width, instant (no animation per DESIGN motion rules), solid red, never glass
- **E7:** SOS screen (`features/sos/`) — full-screen high-contrast dark (no glass), hold-to-send with 2.5 s radial countdown (release-early cancels), fires a queued `sos` outbox entry via `SosRepository` (no location attached — coarse location is a later per-action opt-in), "I'm safe" reset; direct-call tiles via url_launcher: 112 emergency, 108 ambulance, 15100 NALSA legal aid (constants in `SosScreen`, make site-configurable before new regions); "Nearest medical on map" sets the medical filter and returns
- Dev seed adds sample info + warning alerts
- Tests 27 green (alerts ordering + banner, SOS hold-fires-queue, early-release cancels, call tiles present)

**Deferred:** broadcast authoring (needs E5 backend), critical alert sound/vibration (plugin, Phase 2), share-location-with-contact (location opt-in work)

**Next session:**
1. E5 + E8: user creates Supabase project (Mumbai region) and provides URL + anon key → `supabase/` migrations (RLS deny-by-default + negative tests) → swap `UnconfiguredRemoteApi` → anonymous auth → verification queue UI + audit log
2. Small follow-ups: sync scheduling (connectivity listener), freshness/connectivity banner on map
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
