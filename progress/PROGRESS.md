# PROGRESS.md — Build Log
_Newest entry first. One entry per working session._

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
