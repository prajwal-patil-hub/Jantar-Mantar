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
### E6. Alerts feed + broadcast
### E7. SOS screen
### E8. Auth (anonymous device keypair; role claims)
### E9. i18n (en/hi) + accessibility pass

## Board
**Done:** Research · Doc system · E1 scaffold · E2 offline data layer · E3 map · E4 facility detail + submit flow (offline-queued, optimistic pending pins)
**In progress:** —
**Next up:** E5 verification queue (admin) + audit log — needs the Supabase project + first RLS migrations (`supabase/`), or E6 alerts feed if backend setup is deferred another session
**Blocked:** — (before store release: app icon, Android applicationId, tile provider; photo capture waits for the EXIF-strip pipeline; region bulk-download lands with onboarding)

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
