# CLAUDE.md — Jantar Mantar Sahayata

Protest-support app: offline-first Flutter map of facilities (water/food/shelter/medical/safety) with capacity counts. Crowdsourced updates verified before public display. Groups layer on a canonical public map. Privacy-first, security-first.

## Read these first, in order
1. `CONTEXT.md` — vision, all locked decisions, constraints (source of truth)
2. `progress/PROGRESS.md` — last session's log + next tasks
3. `PROJECT_MANAGEMENT.md` — phase board, epics, definition of done
4. `ARCHITECTURE.md` — stack, data model, sync rules
5. `SECURITY.md` — threat model + per-feature checklist (gates every merge)
6. `DESIGN.md` — UI direction (glassmorphism), theming, open design choices
7. `DECISIONS.md` — ADR log; add an ADR for every significant choice
8. Deep reference: `docs/research/ui-ux-spec.md` (every screen, wireframes) and `docs/research/group-architecture.md` (groups, invites, India legal)

## Rules for every session
- Offline-first is non-negotiable: never block UI on network; local-first reads, queued writes.
- Security: no secrets in the app binary; assume all URLs public; authz server-side (RLS deny-by-default); TLS + cert pinning; no tokens in URLs; strip EXIF from photos.
- Privacy: anonymous-by-default auth; coarse location default; minimal group-membership metadata; no phone numbers exposed.
- Accessibility: every status = color + icon + text (never color alone); 48dp+ touch targets; Hindi + English (Noto Sans / Noto Sans Devanagari).
- Performance target: low-end Android (<2GB RAM); cold start to usable cached map <3s; glass blur must have cheap fallback.
- Workflow: pick top "Next up" task from PROJECT_MANAGEMENT.md → build → tick SECURITY.md items → log session in progress/PROGRESS.md → add ADRs.
- MVP scope is frozen: public verified map only. NO groups, mesh, or worldwide features until Phase 3+.

## Current state (2026-07-24, session 5)
Phase 1. E1–E3 complete. App name = **CommonGround** (ADR-12). Backend = Supabase (ADR-8). Flutter 3.44.8 in `app/`, Riverpod 3, strict lints, CI green, 18 tests.
Accent = saffron `#FF6D1F`, dark = system (ADR-10); status colors in `app/lib/core/theme/status_colors.dart` ThemeExtension — never derive status from the seed scheme. Nav = glass docked bar, tiles = standard OSM via FMTC (ADR-13).
Data: Drift schema `core/db/`, repos + sync worker (outbox, backoff) `core/data/`, providers `core/providers.dart`; remote = `UnconfiguredRemoteApi` until Supabase client (E5/E8). Map: `features/map/`, tile provider swappable via `mapTileProviderProvider` (tests stub it). Debug seed pins: `core/db/dev_seed.dart`.
E4 done: detail sheet (`features/map/presentation/facility_detail_sheet.dart`), 5-step submit flow (`features/submit/`), pending pins + Profile counter.
E6 (user side) + E7 done: alerts feed + critical map banner (`features/alerts/`), SOS screen with hold-to-fire + queued outbox entry + direct-call tiles (`features/sos/`, numbers in `SosScreen` constants).
E5 + E8 done (code side): `supabase/` migrations + RLS + decision RPCs + pgTAP negative tests (ADR-14); app sync in `core/data/supabase_remote_api.dart`, `core/data/remote_pull_service.dart`, `core/sync/sync_service.dart`; anon sign-in background; admin login + verification queue in `features/verify/`. Supabase URL/key in `core/config/supabase_config.dart` (public-by-design).
E9 done: i18n via gen-l10n (`lib/l10n/*.arb`, en+hi, typed `AppL10n`), bundled Noto Sans + Noto Sans Devanagari (`assets/fonts/`, Devanagari as fallback), locale toggle in Profile (`core/l10n/locale_provider.dart`, persisted). Localized enum labels in `core/l10n/l10n_labels.dart`; `*_visuals.dart` = icons/colors only. New strings: add to BOTH arb files, run `flutter gen-l10n`. Widget tests building their own MaterialApp must add delegates via `test/support/l10n_harness.dart`.
**MVP core (E1–E9) is code-complete.**
Web run: drift needs `web:` DriftWebOptions + `web/sqlite3.wasm` + `web/drift_worker.js` (committed, version-matched).
Phase 3 (ADR-16): **Groups + E2E chat**. Crypto in `core/crypto/` (X25519 identity in OS keystore, ECIES sealed group-key delivery, AES-GCM messages; server sees only ciphertext). Backend `supabase/migrations/20260725000002_groups.sql` (RLS deny-by-default). App in `features/groups/` (repo + providers + list/create/join/detail with Chat·Members·Amenities). Groups tab = 5th nav destination. Bluetooth mesh chat = NOT building (ADR-17).
**Demo Mode (ADR-18, default ON):** `core/demo/demo_mode.dart`; `DemoGroupsRepository` + demo verification queue + sample events let every screen run with NO backend/login. Toggle in Profile. Demo chat is NOT encrypted — the E2E path is the Supabase one. Both repos implement `features/groups/data/groups_repo.dart`.
Group amenities render on the main map behind a layers toggle (off by default) and are placed via `PickLocationScreen`.
**Offline chat (ADR-19):** Drift schema is **v3** — `CachedGroupMessages` caches group chat as **ciphertext only** (never plaintext; keys stay in the OS keystore). `features/groups/data/group_message_cache.dart`. Reads are local-first: `GroupsRepo.cachedMessages()` = no network, `messages()` = refresh + upsert + rebuild from cache, throws so the UI can show the offline banner. Sends encrypt → persist `pending: true` → drain oldest-first, stopping at the first failure. Any new schema change must extend the `MigrationStrategy` in `core/db/app_database.dart`.
**Key rotation (ADR-20):** removing a member mints group key `epoch+1` sealed to remaining active members. The device keeps ALL epochs (keystore index `group_key_epochs_<group>`); every message carries `key_epoch`, so decrypt with `keys[msg.keyEpoch]`, encrypt with the newest. Queued offline messages are re-sealed to the current epoch in `_flushPending`. Forward secrecy only — never claim it retracts what they already downloaded.
**Broadcasts (ADR-21):** admin announcements are ORDINARY encrypted messages; the broadcast flag + severity live INSIDE the ciphertext (`domain/group_message_payload.dart`, control-char marker) so the server can't tell announcements from chatter. Never write group content to `public.alerts`. Rendered with the alerts treatment in chat + an Alerts-feed section (local cache only), footered "members only".
**QR scanning:** `mobile_scanner` (never `qr_code_scanner`). `inviteCodeFrom()` is the parse boundary for attacker-controlled QR content; falls back to code-paste on web/no-camera/denied.
**Security (Phase 2 done):** `core/security/panic_wipe.dart` (keys first, then all tables, then local sign-out); `core/security/certificate_pinning.dart` — mechanism complete but INACTIVE until `assets/certs/api_roots.pem` exists; generate it with `tool/fetch_api_roots.sh` FROM A TRUSTED NETWORK (a proxy-derived pin is worse than none). `core/media/exif_stripper.dart` decodes+re-encodes photos (bakes orientation first, fails closed); `PhotoPicker` returns only the sanitised copy.
**Testing gates:** drift migrations are covered by `test/core/db/migration_test.dart` against snapshots in `drift_schemas/` — **dump a new snapshot BEFORE every schema change**. RLS negatives run in CI via `supabase/tests/run_local.sh` (no Docker; shim supplies `auth.uid()` etc). `test/core/theme/color_accessibility_test.dart` pins contrast + CVD numbers — improving the palette fails it on purpose.
**E5 closed:** audit-log viewer (`features/verify/presentation/audit_log_screen.dart`, `Icons.history` in the queue AppBar, read-only — `audit_log` has no update/delete policy) + batch approve (opt-in select mode; per-card approve/reject hidden while on; sequential RPCs; reports done/failed counts, never a blanket "done"). Edit-before-approve deliberately deferred (needs a new RPC param + migration).
**E6 closed — critical-alert signals (ADR-24):** `features/alerts/application/critical_alert_signal.dart`. No plugin: `HapticFeedback` + `SystemSound` from `flutter/services`. **Vibration on by default, sound OFF by default** — a chime identifies its owner in a crowd; both toggles in Profile, persisted, loaded in `HomeShell.initState`. Fires once per alert id (`CriticalAlertSignaller._signalled`), never on rebuild/re-sync; `ref.read` for the settings so enabling one later never retro-buzzes. Watched from `CriticalAlertBanner`. Test seam = `alertSignalSinkProvider`.
**Phase 4 started — trust scores (ADR-25):** `supabase/migrations/20260727000003_trust.sql` (USER must apply it). `user_trust` has RLS on and **no insert/update/delete policy at all** — self-promotion is impossible by construction. Tiers `new`→`trusted`(5)→`verifier`(20) behind accuracy gates, recomputed every decision (reversible), promotions+demotions audited. A **verifier is not a small admin**: updates to existing facilities only, never sets `verified_at`, no self-decisions, 30/hour, and **cannot reject** (rejection suppresses; approval is self-correcting). App: `features/verify/domain/trust_standing.dart` + `presentation/widgets/standing_card.dart`; thresholds come from `trust_thresholds()`, never hardcoded. `canVerifyProvider` now includes verifiers. Queue UI mirrors each limit with the reason shown — mirrored, never substituted for the server check. 39 pgTAP assertions total.
**Immediate next task:** corroboration auto-verify (Phase 4) — plus the manual items only a human with hardware can do — two-device E2E chat smoke test (needs the migrations applied + anonymous sign-in enabled), TalkBack/VoiceOver sweep (`docs/accessibility-audit.md`), TLS pin bundle, production tile provider (ADR-13).
Testing gotchas: Riverpod 3 StreamProvider needs `container.listen` before `.future` resolves; end widget tests with `pumpWidget(SizedBox())` + flush pump (drift close timer); avoid `pumpAndSettle` with the map mounted.
Run checks from `app/`: `flutter analyze && dart run custom_lint && flutter test`. Drift codegen: `dart run build_runner build`.

## Don't
- Don't add Google Maps SDK (we use flutter_map + OSM + FMTC — ADR-7).
- Don't make phone-OTP mandatory anywhere (ADR-4).
- Don't store precise user location server-side.
- Don't use Firebase Dynamic Links (dead since Aug 2025) — native App Links/Universal Links only.
- Don't use `qr_code_scanner` (unmaintained) — use `mobile_scanner` + `qr_flutter`.
- Don't put group-scoping logic only in the UI — enforce with RLS + negative tests.
