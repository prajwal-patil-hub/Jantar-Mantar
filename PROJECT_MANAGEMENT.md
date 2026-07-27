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
- [x] **Broadcast authoring (admin)** — `features/alerts/presentation/compose_alert_screen.dart`, reached from the verification queue. Severity + body + mandatory expiry; critical needs a second confirmation; the screen states up-front that this is PUBLIC and unencrypted, unlike a group broadcast (ADR-21)
- [ ] Sound/vibration for critical alerts — needs plugin, Phase 2
### E7. SOS screen
- [x] Full-screen high-contrast SOS: hold-to-send (2.5s radial countdown), release-early cancel, queued through the outbox, "I'm safe" reset
- [x] Direct-call tiles (112 emergency · 108 ambulance · 15100 NALSA legal aid) via dialer; "Nearest medical" jumps to map filtered to medical
- [ ] Share-location-with-trusted-contact — explicit per-use, needs location opt-in work
- [x] Facility **Directions** (platform `geo:` handoff, OSM fallback — no hardcoded Google) and **Share** (public info only, clipboard fallback)
### E8. Auth (anonymous device keypair; role claims)
- [x] Anonymous-by-default via Supabase anonymous sign-in (background, never blocks UI); admin role from server-set app_metadata
- [x] Sync wired: SupabaseRemoteApi push (idempotent client_id), RemotePullService (facilities/capacity/alerts/verdicts), SyncService 60s cycle
- [ ] flutter_secure_storage session hardening + cert pinning · [ ] panic-wipe
### E9. i18n (en/hi) + accessibility pass
- [x] Flutter gen-l10n: en + hi ARB, every user-facing screen localized (nav, map, submit flow, detail sheet, alerts, SOS, profile, admin/verify)
- [x] Bundled Noto Sans + Noto Sans Devanagari (Devanagari as font fallback); instant language toggle in Profile, persisted (ADR-15)
- [x] Accessibility baseline held: status = color+icon+localized-text everywhere; 48dp+ targets; Semantics on pins/SOS; respects system text scale + locale
- [ ] Full TalkBack/VoiceOver sweep across OEMs + CVD-simulator audit → Phase 2 hardening

## Board
**Done:** Research · Doc system · E1–E9 (offline map · submit · sync · anon auth · admin verify · alerts · SOS · **en/hi i18n + a11y baseline**)
**In progress:** USER ACTION: apply `supabase/migrations/` in SQL editor · enable Anonymous sign-ins · create + grant admin account (see `supabase/README.md`)
**Phase 2 hardening — done:** panic-wipe · cert-pinning mechanism (inactive pending a pin bundle) · EXIF-strip photo pipeline · drift migration tests · RLS negatives in CI · automated CVD/contrast audit · app icon · applicationId
**Next up:** the manual items only a human with hardware can do — two-device E2E chat smoke test, TalkBack/VoiceOver sweep (`docs/accessibility-audit.md`), generate the TLS pin bundle from a trusted network (`tool/fetch_api_roots.sh`), pick a production tile provider (ADR-13)
**Blocked:** Live sync until the dashboard steps above are done.

## MVP status: all 9 core epics code-complete. Phase 1 → Phase 2 (hardening) after the device smoke test.

## Phase 3 — Groups + E2E chat (pulled forward per ADR-16, in progress)
- [x] Nav: **Groups** tab (Map · Events · Groups · Alerts · Profile)
- [x] E2E crypto core (`core/crypto/`): X25519 identity, ECIES sealed group-key delivery, AES-GCM messages — 7 tests incl. negatives
- [x] Backend `supabase/migrations/20260725000002_groups.sql`: groups, members, key envelopes, invites, group pins, messages; RLS deny-by-default + member/admin helpers + `resolve_invite`
- [x] UI: groups list, create, join-by-code, group detail (E2E Chat · Members · Amenities), admin invite + member approval
- [x] **Demo Mode** (ADR-18): `core/demo/demo_mode.dart` + `DemoGroupsRepository` behind a `GroupsRepo` interface; sample groups/members/chat/amenities, demo verification queue, sample events. Explore everything with no backend/login; toggle in Profile.
- [x] Group-pin **map picker** (drag-to-place, replaces the hardcoded site centre)
- [x] Group amenities **map layer + toggle** (off by default; square accent pins, visually distinct from public facility pins)
- [x] Events screen localized (en+hi) — was English-only
- [x] **QR invites** — `qr_flutter` invite sheet (scannable QR + copyable code + expiry/approval notice). NOTE: QR *scanning* (`mobile_scanner`) is still to do; it needs a physical device, so joining is code-paste for now.
- [x] **Demo Mode persisted** across launches (SharedPreferences, defensive)
- [x] **RLS negative tests for group tables** (`supabase/tests/rls_groups_negative_test.sql`, 12 assertions: outsider can't read hidden groups / messages / private pins / roster / invite codes / others' sealed keys; can't post or pin; can't self-approve to active; pending member can't read messages) — SECURITY.md gate for groups. Still to RUN via `supabase test db` + wire into CI.
- [x] **Offline chat** (ADR-19): Drift v2 `CachedGroupMessages` (ciphertext only) — chat opens instantly from cache, stays readable with no network behind a visible "Offline — showing saved messages" banner, and messages composed offline are encrypted, queued (`Sending…`, icon + text), and drained oldest-first when the network returns
- [x] **Key rotation on member removal** (ADR-20): admin Remove action → member deleted → new epoch key sealed to everyone who remains; all past epochs kept locally so history survives; offline-queued messages re-sealed under the current epoch before sending; confirm dialog states plainly that it is forward secrecy only. 3 new pgTAP negatives (non-admin cannot issue envelopes or remove members; a removed member loses read access) → **15 group RLS assertions**
- [x] **Group broadcasts** (ADR-21) — admin announcement, encrypted like any message, flag carried inside the ciphertext; alerts treatment in chat + an Alerts-feed section, members-only footer
- [x] **QR scanning** (`mobile_scanner`) — `inviteCodeFrom()` is the parse boundary for attacker-controlled QR content; falls back to code-paste on web/no-camera/denied permission
- [x] **RLS negative tests RUN and in CI** — all 25 assertions pass; `supabase/tests/run_local.sh` needs no Docker; verified to fail when a policy is weakened
- [x] Phase-3 group work complete
- **Bluetooth mesh chat: NOT building** (ADR-17)

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
