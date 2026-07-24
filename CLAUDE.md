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
**Immediate next task:** USER must do the 3 dashboard steps in `supabase/README.md` (apply migration, enable anonymous sign-ins, grant admin role) → then device smoke test → then E9 (i18n/accessibility) or hardening (cert pinning, secure storage, RLS tests in CI).
Testing gotchas: Riverpod 3 StreamProvider needs `container.listen` before `.future` resolves; end widget tests with `pumpWidget(SizedBox())` + flush pump (drift close timer); avoid `pumpAndSettle` with the map mounted.
Run checks from `app/`: `flutter analyze && dart run custom_lint && flutter test`. Drift codegen: `dart run build_runner build`.

## Don't
- Don't add Google Maps SDK (we use flutter_map + OSM + FMTC — ADR-7).
- Don't make phone-OTP mandatory anywhere (ADR-4).
- Don't store precise user location server-side.
- Don't use Firebase Dynamic Links (dead since Aug 2025) — native App Links/Universal Links only.
- Don't use `qr_code_scanner` (unmaintained) — use `mobile_scanner` + `qr_flutter`.
- Don't put group-scoping logic only in the UI — enforce with RLS + negative tests.
