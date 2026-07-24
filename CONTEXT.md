# CONTEXT.md — Single Source of Truth
_Last updated: 2026-07-24_

## Vision
An offline-first, privacy-first app that helps people at protest sites find verified facilities — water, food, shelter, medical aid, safety areas — with live capacity counts ("water for ~200 people"). Starts at Jantar Mantar, Delhi; extensible to a worldwide map of protests and mutual aid.

## Locked decisions
1. **Platform:** Flutter/Dart. Android-first (low-end devices dominate), then iOS, then web.
2. **Data flow:** users submit updates → verification → only verified data shown publicly.
3. **Layered architecture:** one canonical PUBLIC verified map + GROUPS on top. Group-verified updates can be promoted to the public layer; groups also hold strictly private pins (meeting points, supplies).
4. **Groups:** any user can create a group and becomes group admin; manages members/settings. Visibility public/hidden. Join via QR or expiring link (time + max-uses) → mandatory approval queue. Admin can add by opaque user ID (phone-number adding discouraged for privacy).
5. **Auth:** anonymous-by-default (device keypair). Phone-OTP is an optional trust booster, never a gate (OTP fails during SMS jamming).
6. **Offline-first is a hard requirement:** cached map tiles + data, queued writes, freshness banding (fresh <5m / judgment 5–30m / stale >30m), capacity TTL 30–60 min with auto-expiry.
7. **Roadmap staging:** MVP = single public verified map (no groups). Stage 1 = groups (minimal set). Stage 2 = CRDT sync hardening, promotion auto-rules, mesh fallback (best-effort only), worldwide expansion.
8. **UI direction:** minimal + glassmorphism (hero surfaces only, cheap fallback on weak devices), neutral palette + saffron `#FF6D1F` accent (ADR-10; accent never conveys status), rich fluid animations with battery-first/reduced-motion opt-out. Dark mode follows system. Details + remaining open choices: `DESIGN.md`.
9. **Backend:** Supabase (ADR-8 confirmed 2026-07-24) — Postgres RLS deny-by-default, anonymous auth, Realtime, Edge Functions; Mumbai region; self-host escape hatch.
10. **Repo layout:** monorepo (ADR-11) — docs at root, Flutter app in `app/`, Supabase config in `supabase/` when backend work starts.
11. **App name: CommonGround** (ADR-12) — site-neutral so worldwide expansion needs no rename; Dart package stays `jantar_mantar_sahayata`.

## Constraints
- Internet shutdowns/jamming are expected at the site — never block on network.
- Target devices: <2GB-RAM Androids; small APK, data-saver mode, battery care (coarse location default).
- Languages: Hindi + English (Noto Sans / Noto Sans Devanagari).
- Accessibility: color + icon + text for every status (never color alone), 48dp+ targets, high-contrast outdoor mode.

## Privacy & legal ground rules (non-negotiable)
- No precise location stored server-side by default; coarse/opt-in only; minimal retention; panic-wipe.
- Minimal server-side group-membership visibility; hidden groups by default; membership metadata is sensitive.
- India IT Rules 2021: we are an intermediary → grievance officer, takedown workflows, published policy needed before public launch. Re-verify current rules pre-launch.
- Security review + digital-rights org consultation (e.g., SFLC.in / IFF) before any real-world deployment.

## Key personas
- **Protester:** arrives, offline, needs nearest water/shelter fast.
- **Volunteer:** submits capacity updates, member of multiple groups.
- **Group admin:** manages members, verifies group submissions, broadcasts.
- **Platform moderator:** reviews promotions to public layer, suspends abusive groups.

## Reference reports (from research phase)
- UI/UX spec + critique (screen-by-screen, wireframes, 8 weaknesses + fixes)
- Group architecture report (invite security, layered model, India legal, entity sketch)
