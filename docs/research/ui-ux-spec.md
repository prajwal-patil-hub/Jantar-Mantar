# Jantar Mantar Protest-Support App — Complete UI/UX Specification & Critique
_Research report · 2026-07-24 · Reference for all screen builds_

## TL;DR
- Specifies every screen (regular-user + admin), a research-backed design system, three end-to-end persona flows, and a critical "what to fix" analysis for a Flutter offline-first, verify-before-display protest-support map app.
- Biggest design risk: human verification bottleneck + stale capacity data during crowds/shutdowns. Resolved via tiered/trusted-source verification, auto-expiry + staleness banding, full offline read + queued-write model.
- Second biggest risk: protester privacy. Default anonymous accounts, coarse/opt-in location, minimal retention.

## Key findings
1. Ushahidi (most battle-tested crowd-mapping platform) separates *publish status* (under review / published / archived) from a *verified/unverified* trust flag. Emulate this two-axis model, not a single binary.
2. Internet shutdowns at Jantar Mantar are real and recent (July 20, 2026 mobile-internet shutdown during the "Chalo Sansad" march; signal jammers forced people to walk ~2 km to get signal; ~20,000 people arrived within an hour). Offline-first is a hard requirement.
3. Emergency UX principles: one dominant primary action, 48dp+ (56–60dp critical) touch targets, 4.5:1+ contrast, thumb-zone placement, minimal cognitive load, never color alone (~8% of males have red-green color blindness).
4. Offline patterns: local-first read (cached shown instantly), optimistic write with pending-sync queue, freshness banding (fresh <5 min / judgment 5–30 min / stale >30 min).
5. Privacy: location data has been used to identify protesters (Mobilewalla profiled 16,902 devices at 2020 BLM protests from purchased location data). Minimize identity and location precision by design.

---

## Part 1 — Screen-by-screen UI specification

### Global design shell
- Flutter Material 3 (`useMaterial3` default since 3.16), `ColorScheme.fromSeed`.
- Bottom `NavigationBar`, 4 destinations: **Map · Events · Alerts · Profile**. Persistent SOS element. Admin uses a separate queue-first shell (drawer).
- **Persistent connectivity/freshness banner** under app bar: `● Online — synced 2 min ago` (green) / `● Offline — showing saved data from 14 min ago` (amber) / `⏳ Syncing 3 updates…` (blue). Most important recurring component.
- Global "＋ Report" FAB on Map. SOS is NOT the FAB — dedicated red element, 60dp, long-press to fire.
- Noto Sans + Noto Sans Devanagari; body 16sp; labels ≥14sp. Touch targets 48dp min, 56dp primary, 60dp SOS.

### 1.1 Splash / cold-start
Centered logo + loader + "Works offline" line. Offline cold start: skip straight to cached map — never block on a spinner. Corrupt cache: "Couldn't load saved data — Retry / Reset."

### 1.2 Onboarding (3 slides, skippable)
(1) find water/food/shelter/safety on a map, (2) community-submitted + verified, (3) works offline — with "Download Jantar Mantar map & data (≈8 MB)" button + "Do it later."

### 1.3 Auth choice — anonymous vs phone-OTP (critical screen)
- Primary (recommended): **"Continue anonymously"** — no phone number; view everything, submit for review.
- Secondary: **"Verify with phone number"** — trust booster; number never shown to others.
- Tertiary: volunteer/admin login. Bottom: हिन्दी | English toggle + privacy summary.

Trade-off table shown in expandable sheet:
| | Anonymous | Phone-OTP |
|---|---|---|
| Privacy | Highest — no PII | Number stored; SMS metadata at carrier |
| Report trust weight | Baseline | Higher (trusted fast-track) |
| Abuse resistance | Weaker (device rate limits) | Stronger |
| Works during SMS jamming | Yes | **No — OTP undeliverable** |

**Decision:** anonymous default via device-generated keypair/local ID. OTP fails exactly when the app matters most; SMS-OTP is the weakest MFA factor (SIM-swap, interception). OTP-failed state: "Network may be blocked — continue anonymously instead."

```
+------------------------------+
|  Sign in            हि | EN   |
| You can use this app without |
| sharing personal details.    |
| [ Continue anonymously  ▷ ]  |
| [ Verify with phone number ] |
|  Which should I choose? ⌄    |
+------------------------------+
```

### 1.4 Home — Map (core screen)
- Top: search bar ("Search water, food, shelter…") + filter icon; freshness banner beneath.
- Filter chips (scrollable): All · Water · Food · Shelter · Medical · Toilets · Safe area · Danger.
- Full-screen map, **clustered pins** (count bubbles, decluster on zoom). Pins = shape + icon + color, never color alone.
- Bottom: non-modal "Nearby" bottom sheet (drag handle), nearest facilities as cards.
- FABs right (thumb zone): My-location small + "＋ Report" extended. SOS pinned bottom-left, 60dp, deliberate long-press.

Pin semantics: 🟢 Good ✓ · 🟠 Low ! · 🔴 Out ✕ · ◻ grey ? dashed = unverified (opt-in visibility).
States: skeleton pins (not blocking spinner); offline = amber banner + cached tiles; empty = "Be the first to report"; tile failure = grey grid + "Download area?"

```
+----------------------------------+
| ☰  [Search water, food…]     ⏬  |
| ● Offline — saved 14 min ago     |
| (All)(Water)(Food)(Shelter)(Med) |
|            MAP AREA              |
|      (12)     🟢water            |
|         🔴shelter   🟠food       |
|                         [◎ me]  |
|                       [ ＋Report]|
| [SOS]                            |
| ▁▁ Nearby ▁▁                     |
| 🟢 Water point — 60 m — Good     |
+----------------------------------+
```

### 1.5 Facility detail — bottom sheet
Name + type icon + status pill; capacity block (💧 Water for ~200 · 🍲 Food for ~120 · 🛏 Shelter for ~50, large numerals); **last-verified timestamp with freshness color** (green ≤30m → amber → red "Needs re-check" >2h; grey "not yet verified"); photos (lazy, placeholder offline); actions: Directions (works offline via cached route) · Update this · Report closed · Share; trust footer.
Stale state: prominent "This info may be outdated" banner.

### 1.6–1.7 Events list + detail
Cards: title, "Live now" pulsing / "Starts 3 PM", location, verified badge; filters Ongoing/Today/Upcoming; optional on-map toggle. Detail: hero, organizer, linked nearest resources as mini-cards, map snippet, safety notes, Directions/Share.

### 1.8 Submit-an-update flow (5 steps, fully offline-capable)
1. **Category** big icon grid (2-col, 88dp): Water/Food/Shelter/Medical/Toilet/Safe/Danger.
2. **Location**: "Use my current spot" (coarse default) / drag pin / pick existing → "Update existing" vs "Add new". Duplicate hint: "similar water point 30 m away — update it instead?"
3. **Capacity**: big +/− steppers (48dp, no keyboard) + presets (~50/~100/~200/500+).
4. **Status + photo**: Good/Low/Out segmented; optional camera (auto-downscale/WebP); optional note (voice-friendly).
5. **Review → "Submit for verification."** Offline: "Saved — will send when connection returns."
Optimistic: appears on submitter's map as grey dashed "Pending (yours)"; pending-uploads tray with count in Profile.

### 1.9 SOS screen
Full-screen high contrast; huge central "SOS — Hold to send" (2–3s radial countdown); tiles: Call police / ambulance / legal-aid; Share location with trusted contact (explicit, per-use); Nearest medical; "I'm safe" reset. Offline: queue + try fallback + direct call always available.

### 1.10 Alerts feed
Severity-banded cards (Info/Warning/Critical) + icon + timestamp + area chip + "Verified by admin". Critical pinned + full-width map banner + optional sound/vibration. Offline: cached + "may be outdated."

### 1.11 Search
Full-screen; recents + suggested chips; grouped results (Facilities/Events/Areas) with status pills + distance; searches local cache offline (noted).

### 1.12 Profile / settings
Account (anon ID / masked phone, "Upgrade trust with phone", trust badge) · Pending uploads (retry/cancel/sync-now) · Language toggle (instant) · Offline data (download ≈8 MB, auto-update on Wi-Fi, **Data-saver mode**) · Appearance (Light/Dark/**High-contrast outdoor**, text size) · Notifications (severity) · Privacy (location precision Precise/Coarse/Off, Clear my data, **panic-wipe**) · About/Help.

### 1.13 Shared patterns
Empty = illustration + one-line cause + one action. Offline = never a dead-end; cached data + amber banner + what-still-works. Error = plain language + Retry, no stack traces. Skeletons everywhere, not spinners.

### Admin shell (drawer): Verification Queue · Facilities · Announcements · Co-admins · Audit Log · Analytics

### 1.14 Verification queue (admin core)
Counts ("42 pending · 8 flagged urgent · 3 duplicates"); filters (type/area/age/source-trust); submission cards: thumbnail, category, capacity, submitter trust chip, age timer, auto-flags (duplicate / trusted ✓). Actions: Approve (green) / Reject (red, reason required) / Merge / Edit & approve. Batch multi-select "Mark as". Two-axis model: publish status (under review→published→archived) ⊥ verified flag. Edit-lock ("Being reviewed by co-admin X"; admin can override). Offline: last-synced queue, actions queue.

### 1.15 Approve/reject with reason
Full submission detail + decision buttons; Reject reason picker (Duplicate / Can't verify / Stale / Inaccurate / Spam / Other + note); Approve: optional "Mark verified" + expiry override; preview of what users will see.

### 1.16 Manage facilities
CRUD canonical facilities; force re-verify; archive/close; update history; cross-co-admin edit locks.

### 1.17 Broadcast announcement
Severity, title, body, target area (map-draw or all), schedule/now, ack-required toggle, user-facing preview; recall/expire; offline-queued with delay warning.

### 1.18 Manage co-admins
Role chips (Admin/Co-admin/Moderator/Trusted volunteer); invite via QR/code (works offline in-person); permission matrix; suspend/revoke; **emergency promote**.

### 1.19 Audit log
Filterable chronological (who/what/when/before→after): approvals, rejections+reasons, edits, broadcasts, role changes, overrides. Export. Read-only.

### 1.20 Analytics (light)
Pending/verified over time, median verification latency, most-requested resources, stale hotspots.

---

## Part 2 — Research-backed design guidance
- **Two-axis data model** (Ushahidi): visibility/publish status ⊥ verified trust flag; per-type "review before publish" toggle (low-risk types can auto-publish; danger alerts always reviewed).
- **Crisis card** (Google Maps): expandable crisis sheet with summary + resources + report action → model for alert banner.
- **Duplicate SOP** (Ushahidi): merge newest content into canonical, archive duplicate, link via related-post → the Merge action.
- **Clustering** essential at density.
- **Stress design**: one dominant action; 48–60dp targets; ≥4.5:1 contrast; thumb-zone; confirmation for irreversible actions; progressive disclosure via bottom sheets.
- **Low-end/poor connectivity**: skeletons + optimistic UI; Data-saver (skip/downscale images to WebP, low-res tiles, gzip); small install; test on <2GB-RAM (30%+ of global Androids).
- **Offline UX**: local-first read; freshness banding <5m/5–30m/>30m; queued writes with guaranteed delivery + visible sync badges; never dead-end.
- **Accessibility**: never color alone (WCAG 1.4.1; red-green CVD ~8% of males); TalkBack/VoiceOver via Flutter Semantics (test across OEMs); elderly: ≥16px, adjustable size, simple labels, voice input; WCAG 2.1 baseline.
- **Material 3**: `ColorScheme.fromSeed`, M3 NavigationBar, filled/tonal buttons, three Card variants, careful surfaceTint; single design language, selective Cupertino.

---

## Part 3 — What can be done better (weakness → solution)
1. **Verification bottleneck** → tiered verification: auto-publish low-risk types; trusted-source fast-track; corroboration threshold (N independent matching reports auto-verify); admins handle flagged/critical only.
2. **Stale capacity data** → TTL 30–60 min per reading; visual degrade → "may be outdated" → auto-archive; prompt nearby users "Still available? Yes/No". (Ushahidi has no auto-expiry — our extension.)
3. **Single admin failure** → co-admin roles + emergency promotion; offline QR role-granting; quorum for critical broadcasts.
4. **Trust & misinformation** → per-submitter trust scores; reject-with-reason + audit; corroboration; report-this-pin; outlier auto-flags.
5. **Location privacy** → anonymous default; coarse/opt-in; no precise history; minimal retention; panic-wipe; aggregate presence only.
6. **Battery drain** → coarse/network location default (~30% saving vs continuous GPS); 2–5 min update interval, pause when still; cached tiles; dark/battery mode; no background GPS.
7. **Total connectivity loss** → full offline read + queued writes; optional BT mesh relay for critical alerts, best-effort only (heavy battery ~4x; Bridgefy has documented security failures — never for sensitive data).
8. **Anonymous abuse** → device rate limits; CAPTCHA only when suspicious; trust-graduated posting limits.

---

## Part 4 — Persona flows
**A. Protester (offline):** Splash → cached Map (amber banner) → Water chip → 🟢 pin 60m → sheet "Verified 8 min ago" → Directions (cached) → Shelter chip → amber-freshness pin treated as uncertain → checks alternative → Critical alert banner guides away from danger. Zero network blocking.
**B. Volunteer submitting:** ＋Report → Food → current spot (coarse) → detects existing stall 20m → Update existing → steppers ~120 → Low + photo → Submit → offline-queued → grey "Pending (yours)" → syncs later → verified after admin approval.
**C. Admin triaging:** Queue 42 pending → filter Critical + trusted → approve trusted "water out" + mark verified → merge duplicate → reject uncorroborated "safe zone" with reason → batch-approve corroborated water reports → broadcast Critical lathi-charge alert → emergency-promote co-admin.

---

## Part 5 — Component & design-system recommendations
- **Nav:** users = bottom NavigationBar (4 items); admin = drawer. Map default.
- **Map:** clustered pins; non-modal Nearby sheet + modal detail sheet; offline tiles via flutter_map + FMTC (or Mapbox offline packs); region download at onboarding.
- **Capacity colors + redundancy:** Good `#2E7D32` ✓ · Low `#F9A825` ! · Out `#C62828` ✕ · Unverified grey ? dashed. Always icon + label. CVD-simulator audit each release; blue-scale option in high-contrast mode. Freshness uses separate cue (timestamp + border tint).
- **Icons:** Water 💧 Food 🍲 Shelter 🛏 Medical ✚ Toilet 🚻 Safe 🛡 Danger ⚠ Charging 🔌 Legal ⚖ — filled, ≥24dp, always with text.
- **Type:** Noto Sans + Noto Sans Devanagari; extra line-height for Devanagari (stacking matras/conjuncts); no tight tracking; base 16sp scalable; usability-test Hindi separately.
- **Themes:** Light / Dark / High-contrast Outdoor (sunlight); dark saves OLED battery.

---

## Staged recommendations
**MVP:** anonymous auth, offline map (tiles+data), pins with capacity + freshness + auto-expiry, submit flow (queued), verification queue (approve/reject/merge + audit), alerts broadcast, SOS, hi/en, data-saver + dark/outdoor. Defer: worldwide, mesh, analytics.
**Stage 1 trigger:** median verification latency >~15 min during live event → add tiered verification, trusted fast-track, corroboration auto-verify (e.g., 3 independent reports / 200m / 30min), trust scores, co-admin + emergency promotion.
**Stage 2:** mesh (best-effort), multi-site → worldwide, analytics, more languages.
**Always-on guardrails:** TTL 30–60 min; cold start <3s on <2GB device; color+icon+text everywhere; no precise server-side location; panic-wipe.

## Caveats
- Thresholds (TTL, corroboration counts) are proposals to field-validate.
- Mesh: Bridgefy security broken twice (2021 CT-RSA, 2022 USENIX); battery-heavy; non-sensitive critical alerts only.
- OTP fails during shutdowns — deliberate trade-off behind anonymous default.
- Legal/threat-model review with digital-rights org (SFLC.in / IFF) before launch.
- UX figures are industry conventions — validate on real target devices/users.
