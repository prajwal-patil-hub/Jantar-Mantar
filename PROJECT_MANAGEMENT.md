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
- [ ] Local DB (Drift) schema: Facility, Submission, Alert, SyncQueue
- [ ] Repository pattern: local-first read, queued writes, sync worker
### E3. Map
- [ ] flutter_map + OSM tiles + FMTC offline tile caching
- [ ] Clustered pins, filter chips, freshness banding UI
### E4. Facility detail + submit flow (5-step, queued offline)
### E5. Verification queue (admin) + audit log
### E6. Alerts feed + broadcast
### E7. SOS screen
### E8. Auth (anonymous device keypair; role claims)
### E9. i18n (en/hi) + accessibility pass

## Board
**Done:** Research (features, UX spec, groups) · Doc system (this) · E1 scaffold (backend confirmed, Flutter app in `app/`, lints + CI)
**In progress:** —
**Next up:** E2 offline data layer (Drift schema: Facility, Submission, Alert, SyncQueue → repositories → sync worker)
**Blocked:** — (open before E3: DESIGN.md choices 3–5 — app name/icon, nav bar treatment, tile style; Android applicationId still `com.example.jantar_mantar_sahayata`, must be finalized before any store release)

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
