# PROJECT_MANAGEMENT.md
_Last updated: 2026-07-24 · Phase 0_

## Phases
| Phase | Goal | Exit criteria |
|---|---|---|
| **0 — Foundation** | Docs, stack confirmed, Flutter scaffold runs | App boots on emulator; CI lint passes |
| **1 — MVP core (public map)** | Offline map + facilities + submit + verify + alerts + SOS | Cold start → usable cached map <3s on low-end device; end-to-end submit→verify→display works offline→sync |
| **2 — Hardening** | Security pass, accessibility pass, Hindi | MASVS-L1 checklist green; CVD-simulator audit; TalkBack pass |
| **3 — Groups (Stage 1)** | Minimal group set per research | Create/join/approve/private-pins all RLS-enforced |
| **4 — Scale** | Promotion rules, moderator tooling, multi-site | Trust-score promotion live; second site onboarded |

## Epics → tasks (MVP)
### E1. Project scaffold
- [x] Confirm backend: **Supabase** (ADR-8 confirmed 2026-07-24)
- [x] `flutter create` + folder structure (feature-first, Riverpod) — `app/`, Flutter 3.44.8, Riverpod 3.1
- [x] Lint rules, CI (analyze + test), git repo — strict analysis_options + riverpod_lint; GitHub Actions (`.github/workflows/ci.yml`)
### E2. Offline data layer
- [x] Local DB (Drift) schema: Facility, CapacityReading, Submission, Alert, SyncQueue (`app/lib/core/db/`)
- [x] Repository pattern: local-first read (Drift streams), queued writes (submission + outbox in one transaction), sync worker (exponential backoff 2s→10min cap, maxAttempts→failed, manual retry) — remote API stubbed until Supabase client lands (E5/E8)
### E3. Map
- [x] flutter_map 8 + OSM tiles + FMTC 10 offline tile caching (network fallback if FMTC can't start; OSM attribution shown)
- [x] Clustered pins (status = color + icon + text), filter chips, freshness banding UI (FreshnessBadge), Nearby sheet (map-center distance, no GPS), pin-tap peek sheet, Report FAB + SOS placeholders
### E4. Facility detail + submit flow (5-step, queued offline)
- [x] Facility detail sheet: status pill, capacity numerals with TTL degrade, freshness + stale banner, Update this / Report closed (Directions/Share/photos stubbed)
- [x] 5-step submit flow: category grid → drag-pin location (map center start, duplicate hint ≤60m) → capacity steppers/presets → status + note (photo deferred to EXIF-strip task) → review → offline submit
- [x] Optimistic grey "Pending (yours)" pins for new-facility submissions; pending-uploads counter in Profile
### E5. Verification queue (admin) + audit log
- [x] `supabase/` schema: tables, RLS deny-by-default, `approve_submission`/`reject_submission` SECURITY DEFINER RPCs writing append-only audit_log (ADR-14); pgTAP negative tests written
- [x] Admin login (email/password) + verification queue UI: oldest-first pending cards, approve / reject-with-reason
- [ ] Run RLS negative tests via `supabase test db` + add to CI · [ ] merge/edit-approve/batch actions · [ ] audit log viewer UI
### E6. Alerts feed + broadcast
- [x] Alerts feed: severity-banded cards (icon+label+color; info blue distinct from status colors), critical pinned first, timestamps, verified-by-admin note, offline "may be outdated" footer
- [x] Full-width critical banner on the map — instant, no animation, never glass
- [ ] Broadcast authoring (admin) — lands with E5 backend
- [ ] Sound/vibration for critical alerts — needs plugin, Phase 2
### E7. SOS screen
- [x] Full-screen high-contrast SOS: hold-to-send (2.5s radial countdown), release-early cancel, queued through the outbox, "I'm safe" reset
- [x] Direct-call tiles (112 emergency · 108 ambulance · 15100 NALSA legal aid) via dialer; "Nearest medical" jumps to map filtered to medical
- [ ] Share-location-with-trusted-contact — explicit per-use, needs location opt-in work
### E8. Auth (anonymous device keypair; role claims)
- [x] Anonymous-by-default via Supabase anonymous sign-in (background, never blocks UI); admin role from server-set app_metadata
- [x] Sync wired: SupabaseRemoteApi push (idempotent client_id), RemotePullService (facilities/capacity/alerts/verdicts), SyncService 60s cycle
- [ ] flutter_secure_storage session hardening + cert pinning · [ ] panic-wipe
### E9. i18n (en/hi) + accessibility pass

## Board
**Done:** Research · Doc system · E1–E4 · E6 (user side) · E7 · E5+E8 core (schema+RLS+RPCs, sync push/pull, anon auth, admin queue UI)
**In progress:** USER ACTION: apply `supabase/migrations/` in SQL editor · enable Anonymous sign-ins · create + grant admin account (see `supabase/README.md`)
**Next up:** End-to-end smoke test on a device → then E9 (i18n hi/en + accessibility pass) or hardening follow-ups (cert pinning, secure storage, RLS tests in CI, broadcast authoring UI)
**Blocked:** Live sync until the dashboard steps above are done. Before store release: app icon, applicationId, tile provider, EXIF-strip pipeline, region bulk-download.

## Definition of Done (every task)
1. Works offline (or degrades gracefully with visible state)
2. Relevant SECURITY.md checklist items ticked
3. Status conveyed by color + icon + text
4. Logged in progress/PROGRESS.md

## Risks (top 3, live)
| Risk | Mitigation |
|---|---|
| Verification bottleneck at scale | Tiered verification (Stage 1), corroboration auto-verify |
| Protester privacy / metadata exposure | Anonymous default, coarse location, minimal membership visibility |
| Solo-dev scope creep | Strict MVP cut: no groups, no mesh, no worldwide until Phase 3+ |
