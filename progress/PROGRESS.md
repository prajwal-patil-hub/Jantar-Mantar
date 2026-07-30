# PROGRESS.md — Build Log
_Newest entry first. One entry per working session._

## Session 25 — 2026-07-30 · Component-state audit: depth, the three async states, and offline (ADR-33)
**Done:**
- **Audited rather than guessed.** Counted actual occurrences across all 21 screens: `BoxShadow` in 2 files, `Semantics` in 4, zero `AnimatedSwitcher`/`Skeleton`/`SnackBarTheme`/`FocusNode`, and one `RefreshIndicator`. That is the gap list, not an opinion.
- **Depth turned out to be a bug I introduced.** Soft Geometry is tone-on-tone, and a shell card on the sand scaffold measures **1.15:1** — dark 1.11:1 — against the 3:1 WCAG 1.4.11 wants for a component boundary. So cards were, strictly, invisible as cards. Fixed with two mechanisms because one is not enough: a warm-tinted shadow (grey on a warm ground reads muddy) and a hairline that clears 3:1 against *both* the card and the ground, which is what survives direct sunlight and the no-blur outdoor path. Both pinned in the test so neither gets tidied away as ornament.
- **The three async states are one decision** — what a screen says when it has nothing to show. Empty was a lone centred sentence; loading was a spinner on a blank screen, indistinguishable from broken; error printed `'$e'` verbatim. `EmptyStateView`, `LoadingStateView` (skeleton in the shape of the content, staggered, still under reduced motion *and* battery saver) and `ErrorStateView` replace all three. **The raw exception never reaches the headline** — it tells a volunteer nothing and shows Postgres internals to whoever is reading over their shoulder — but it is folded behind a disclosure rather than discarded, so debugging still works. A test asserts both halves.
- **Offline is finally stated.** The app has been offline-first since E2 and only group chat ever said so; a frozen map and a live map looked identical. `OfflineBanner` sits above every tab, driven by **whether the backend actually answered** rather than by a connectivity plugin — "the radio says Wi-Fi" and "the backend answered" disagree during exactly the internet shutdown this is built for, and it adds no Android permission. Unknown reads as online, so nothing claims staleness before the first cycle runs.
- Snackbars and dividers themed — snackbars are this app's main feedback channel (every approve, reject, save and share ends in one) and were stock Material rectangles against the new palette.
- **Found and fixed a real leak:** the skeleton's stagger used a bare `Future.delayed`, which left a pending timer past dispose and failed teardown in every widget test that mounted a loading screen. Now a cancellable `Timer`, with a regression test.
- Wireframe artifact extended to 25 frames with the loading, empty, error and offline states.
- 196 tests green (+11); analyze + custom_lint clean.

**Still open, and named rather than implied:** no focus-visible treatment (`FocusNode` count is still zero), `Semantics` coverage is 4 files, no pull-to-refresh on most lists, and no shared transition/motion vocabulary. Those are the next component pass.

**Next:** the per-screen pass (screens that hand-roll containers), then the server half of route reports.
---
## Session 24 — 2026-07-30 · Soft Geometry: a shape language extracted from reference images (ADR-32)
**Done:**
- **Extracted the geometry, not the pixels.** The supplied sheets reduce to one idea — a stadium field with a circular action attached, and five ways of joining them (lens split, notched knob, dropped tab, corner cap, bleeding disc) — plus a layout vocabulary of card-per-row, 22–28 px panels, pill CTAs and about double the vertical breathing room. Method and the reusable image→UI prompt are in `docs/research/ui-shape-language.md`.
- **Drew all 21 screens** in the new language and published them as a wireframe artifact, theme-aware, viewable on a phone.
- **Adopted it as tokens, not as screen styling.** Surface ramp, action tone and a radii scale go through `AppTheme`'s component themes, so card, chip, dialog, sheet, input, list tile and buttons all pick it up at once. `NotchedActionField` and `CappedSurface` cover the two joins the app uses — a shape language enforced by discipline drifts; one enforced by a shared widget cannot. Filled/outlined buttons are now pinned to the 56 dp emergency target rather than Material's default 40.
- **`StatusColors` is untouched, and that was the main design decision.** Good/Low/Out/Unverified must stay separable under colour-blindness; a brown-on-tan monochrome collapses exactly the distinction the map exists for. The warm palette applies to chrome only.
- **Measured every colour instead of asserting it, and three decisions changed because of it:** the light sand ground costs ~1 point of contrast but every swatch still clears 3:1; the warm dark ground `#160F0A` actually *raises* the weakest from 3.00 to 3.06 versus the old `#141218`; the first clay `#A5713F` put cream labels at 3.93:1 — under the body bar — so it darkened to `#8C5A29` at the same hue; and dark mode needed an inverted label token after cream-on-clay measured 2.83:1. **Both of those last two were caught by the tests, not by eye.**
- **Found a real pre-existing bug:** `color_accessibility_test.dart` was measuring against a hardcoded near-white and near-black that no screen ever painted. It now reads `AppTokens` and measures the *scaffold* — the worse of the two light surfaces — so the numbers mean something.
- 185 tests green (+2 new contrast assertions); analyze + custom_lint clean.

**Not done, and stated rather than implied:** shapes 1, 3 and 5 are specified and drawn but not built as widgets — 2 and 4 cover current needs. Screens that hand-roll a container instead of using `Card`/`Chip`/`FilledButton` still need a per-screen pass; the theme covers the majority but not all of them.

**Next:** the per-screen pass, then the server half of route reports.
---
## Session 23 — 2026-07-30 · Route hazards: edges, not points (ADR-31, schema v4)
**Done:**
- **Closed the largest model gap the disaster research found.** The map only ever held points. The Venezuela case — an aftershock collapsing a bridge and cutting a parish off mid-response — cannot be expressed by a pin. Drift **v4** adds `RouteReports`: two endpoints, a condition, a cause, a mandatory expiry; drawn as a line under the marker layer.
- **There is no `open` condition, and a test locks the enum.** This is the whole design. Crowd data can report a hazard; it cannot certify a road is safe, and showing "open" to someone deciding whether to drive into floodwater is a life-safety claim the app has no basis for. `cleared` means "this was reported blocked and someone has since got through" — a retraction — and renders thin and dotted so it can never read as a safe-route highlight. While any hazard line is on screen the map says outright that an unmarked road has **not** been checked.
- **Expiry is not nullable.** A stale blockage diverts people away from what may be the only viable road, so reports age out and must be re-asserted. The report screen explains that rather than silently enforcing it, and a test asserts nothing can be saved open-ended.
- **A segment, not a polyline editor**: two taps, one-handed, no GPS — placement reuses the move-the-map-under-a-crosshair pattern.
- **Honest about scope:** reports are local-only. The UI says "Saved on this device. Route reports do not sync yet" rather than "submitted for verification", which would be false until the server table exists.
- **Followed the schema gate properly for once without being reminded**: dumped `drift_schema_v4.json` *before* wiring anything, regenerated the migration helpers, extended the sweep to cover v1→v4/v2→v4/v3→v4, and added a v3→v4 data-survival test. Then checked it bites — deleting the index creation turns it red, the same class of bug that was caught in v2.
- Guwahati demo seed gains three route reports (impassable / difficult / reopened) so all three renderings are visible in Demo Mode.
- **183 tests green (+10)**; analyze + custom_lint clean.

**Next:** the server half of routes (table, RLS, verification path, corroboration), then read-only CAP ingest, then the Wi-Fi LAN transport.
---
## Session 22 — 2026-07-30 · Disaster adaptation: research, threat-model inversion, and the number nobody had
**Done:**
- **Researched current reporting** (see `docs/research/disaster-response-adaptation.md`, sources inline): Assam floods July 2026 — 6.54 lakh affected, 274 camps; one camp of **15,000 people with 6 latrines and 3 hand pumps**, another **13,000 with 3 latrines**; ~20,000 diarrhoea cases. Venezuela earthquakes June 2026 — an aftershock collapsed a bridge and cut a parish off mid-response. Misinformation half-life under **two hours**, faster than any verification cycle. India's CAP alert system (SACHET) launched 2 May 2026 then was **temporarily suspended**.
- **The finding that mattered:** against Sphere/UNHCR minimums (≤50 people per latrine in the first phase) those camps were running at **2,500 and 4,333 per latrine** — 50× to 87× over. The failure was not that someone judged that acceptable. **Nobody had the number.**
- **Built the number (ADR-30).** `core/domain/sphere_standards.dart` computes people-per-latrine and people-per-water-point for any relief camp from data the app *already* holds — a shelter's stated capacity over the usable toilet/water facilities mapped within 150 m. No new collection, no schema change, no permissions, no personal data. Surfaced as a card in the facility sheet that names the standard beside the ratio.
- **It refuses to guess, in four tested ways:** a latrine marked `out`/`closed` counts as **zero** (counting broken provision turns a failing camp into a compliant one on paper); no headcount renders **nothing**, never "adequate"; the radius is generous, which over-counts provision and errs toward *less* alarm; and water is reported as a band between the two published thresholds rather than a fabricated single figure, because the model cannot tell a tap from a hand pump.
- **Corrected my own research doc** mid-build: it claimed the module would compute litres/person/day. Flow rate is not in the data model, so that was not computable and the doc now says what the code actually does.
- **The threat model inverts, and that is the real deliverable.** Disaster is not a friendlier context — it produces a population that is locatable, desperate and predictable. §3 of the doc has a **never-build list**: no evacuated-homes or aid-delivered layer (documented looting pattern — it is a burglary itinerary with a refresh button); no public vulnerability register; no missing-persons board (personal data on people who cannot consent — link to ICRC Restoring Family Links instead); no free-text URLs or payment details in public pins (scam domains are registered before the storms are even named); and no client-side "disaster mode" that relaxes verification. Plus: never add contributor leaderboards, because trust tiers already create a linkable pseudonym and "the person who reports the water every morning" is identifiable in a camp of 200.
- Guwahati added as a fourth map site with a seeded relief camp (8,000 people, 4 latrines of which 2 unusable) so the card is explorable in Demo Mode on a phone.
- **173 tests green (+18)**; analyze + custom_lint clean; web build green.

**Next (needs a decision, not just time):** road/route status is the biggest genuine model gap — the app maps points, a disaster needs edges. Then read-only CAP ingest, and the Wi-Fi LAN transport, whose main objection (radio emissions identifying you) largely lifts in a disaster while cell networks fail first.
---
## Session 21 — 2026-07-28 · Ed25519 sender signatures (ADR-29)
**Done:**
- **Found the gap while analysing the Wi-Fi transport, then closed it.** Group messages are AES-GCM under a key *shared by the whole group* — that proves a message came from someone holding the key, not from **which member**. Sender identity was being attested by the server (`messages_member_send` enforces `sender_id = auth.uid()`). Real control, but it is the server's word, and it is exactly the guarantee that disappears the moment the transport is not a server. The plausible attack here is a forged "the medical tent has moved" from a trusted organiser.
- **Each device now publishes an Ed25519 signing key** (`device_keys.signing_public_key`) alongside its X25519 identity — two keys because an X25519 key cannot sign — and signs a domain-separated blob covering **group id + key epoch + the whole AEAD box**. So a signature cannot be lifted into another group or replayed under another epoch, both asserted.
- **`_reseal` now re-signs as well as re-encrypts.** A message queued offline before a key rotation (ADR-20) is re-sealed to the new epoch on send; carrying the old signature over would have made our own message verify as *invalid* on every recipient's device. Caught while writing the epoch-binding test.
- **The downgrade case is the subtle half.** Simply not signing is indistinguishable from an old client — *unless* the sender has already published a key. So "unsigned from a sender who has a key" = **invalid**; "unsigned from a sender with no key" = merely **unsigned**. Only `invalid` reaches the UI: during rollout most messages are legitimately unverifiable, and warning on all of them would train people to ignore the one warning that matters.
- **The RLS rule that already existed is what makes any of this mean anything** — `device_keys` writes only to `user_id = auth.uid()`, so nobody can publish a signing key on someone else's behalf. Now asserted by three new pgTAP negatives (forge a key row, swap an existing one, and the positive that members *can* read the roster to verify with).
- Signature lives **inside the envelope**, not in a `group_messages` column, so it rides any transport — including the proposed LAN one — for free.
- Panic-wipe already used `keyStore.deleteAll()`, so the new seed and the cached signer rosters are covered; a test asserts a wiped device gets a different signing key.
- **155 tests green (+9) and 64 pgTAP assertions.** Verified the crypto tests bite: stubbing `_verify` to always return `valid` turns all five forgery/downgrade/binding tests red.

**Needs the user:** apply `supabase/migrations/20260728000006_signing_keys.sql` (after trust → corroboration → moderation). It is an additive nullable column; existing installs keep working and start signing the next time they open the app.

**Next:** unchanged and still hardware-bound — two-device E2E chat smoke test (now also the way to see signatures verify end to end), TalkBack/VoiceOver sweep, TLS pin bundle from a trusted network, production tile provider. The Wi-Fi transport itself is still a decision, not a task: `docs/research/offline-wifi-transport.md`.
---
## Session 20 — 2026-07-28 · E7 closed (share location) · moderator brake on promotion
**Done:**
- **Share my location (E7, ADR-28)** — the last non-hardware MVP gap. This is the **only** GPS in the app and the constraints are the feature: a consent sheet explains what one reading does and who can see it *before* the permission prompt appears; `getCurrentPosition` only, never a stream, never background, and `ACCESS_BACKGROUND_LOCATION` is deliberately absent from the manifest. The fix goes straight to the OS share sheet — never Drift, never the outbox, never Supabase, because "don't store precise user location server-side" is not satisfied by "we only keep it briefly". Link is OpenStreetMap, so the recipient does not have to tell Google where the sender is to read it.
- **A denied or failed fix says so explicitly** ("Nothing was shared"). A share that silently does nothing would leave someone unsure whether their position went out, which is the worst possible ambiguity here.
- **Moderator brake (ADR-27)** — automatic promotion only demotes accounts that are *wrong*; it says nothing about one that is accurate and hostile. `revoke_verifier` drops an account to New **and holds it there**. The hold is the entire point: without it the next approved report recomputes the tier and hands the badge straight back. The decisive test credits 30 approvals to a held account and asserts it is still New — and it goes red the moment the hold check is removed.
- `restore_trust` **recomputes from the counters** rather than restoring the old badge, and `reporter_history` is SECURITY INVOKER so RLS still decides who may read whose submissions — a verifier calling it gets their own record and an empty list for anyone else. Reached from a person icon on each queue card.
- Corrected a stale checkbox: E8's "secure storage + cert pinning + panic-wipe" had been done in Phase 2 but was never ticked.
- 146 tests green (+11) and **61 pgTAP assertions**; analyze + custom_lint clean; web build green.

**Needs the user:** apply the migrations in order — `..._trust.sql` → `..._corroboration.sql` → `..._moderation.sql`.

**Next:** nothing left that this container can build. What remains is hardware- or network-bound: two-device E2E chat smoke test, TalkBack/VoiceOver sweep (`docs/accessibility-audit.md`), the TLS pin bundle generated from a trusted network, and choosing a production tile provider (ADR-13).
---
## Session 19 — 2026-07-27 · Corroboration auto-verify
**Done:**
- **`supabase/migrations/20260727000004_corroboration.sql`** — an AFTER INSERT trigger: when 3 **distinct** reporters agree on the same facility AND the same status inside 20 minutes, it publishes with no human decision at all. Trust promotion (ADR-25) adds more people who *can* approve; this handles the case where nobody is available.
- **The whole design is the sock-puppet defence.** Anonymous sign-in is free, so "three users agree" is worth nothing by itself. Only accounts at tier `trusted` or better count — five admin-approved reports **each** to get there — and a test files a full quorum of three fresh accounts and asserts nothing publishes.
- **Corroborated approvals deliberately do NOT credit trust.** Without that, a ring of three trusted accounts could corroborate each other all the way to verifier and never face an admin again. That is asserted too.
- Same narrow envelope as a verifier: existing facilities only, `verified_at` untouched, so the worst case is a status flip on a known pin that the next report corrects. Disagreeing reports stay in the queue for a human.
- **The audit row has `actor_id = NULL` on purpose** and names every submitter, so a colluding ring is reconstructible. The audit viewer renders that null as "automatic — no admin decision" rather than a blank or a dash, and now also labels promotions/demotions.
- 10 new pgTAP negatives (**49 total**), and I checked they bite: dropping the trust gate turns assertions 3 and 4 red.
- 135 tests green; analyze + custom_lint clean.

**Needs the user:** apply BOTH new migrations (`..._trust.sql`, then `..._corroboration.sql`) in the Supabase SQL editor, in that order — the corroboration trigger reads `user_trust`.

**Next:** what is left is genuinely hardware- or network-bound: two-device E2E chat smoke test, TalkBack/VoiceOver sweep (`docs/accessibility-audit.md`), TLS pin bundle generated from a trusted network (this container's egress terminates TLS, so a pin derived here would be worse than none), and picking a production tile provider (ADR-13).
---
## Session 18 — 2026-07-27 · Phase 4 begins: trust scores and a deliberately narrow verifier
**Done:**
- **`supabase/migrations/20260727000003_trust.sql`** — `user_trust` counts approved/rejected submissions per account and recomputes a tier on every decision: `new` → `trusted` at 5 approvals → `verifier` at 20, each behind an **accuracy gate** (4:1 and 9:1), so volume alone never buys standing.
- **Self-promotion is impossible by construction, not by a check.** The table has RLS on and *no* insert/update/delete policy at all; the only writer is a SECURITY DEFINER function. A test proves a verifier cannot even see another user's row, let alone write it.
- **The verifier role is narrow on purpose** and that is the whole design: approve **updates to existing facilities only** (never mint a pin on the canonical map), approvals publish with `verified_at = NULL` — precisely what ADR-2's two-axis model exists for — cannot decide their own submissions, rate-limited to 30/hour, and **cannot reject anything**. Rejection stays admin-only because an approval is self-correcting (more reports keep arriving) while a rejection silently removes information from the queue, which is exactly what a hostile verifier would do.
- **Trust is reversible.** The tier is recomputed, never latched, so an account that builds standing and then starts posting garbage loses it without an admin intervening. Promotions *and* demotions are written to the audit log.
- **The queue UI mirrors every limit with the reason shown** — a verifier sees Reject greyed out with "Rejecting is admin-only", and Approve greyed out on a new-facility submission with "A new facility needs an admin". Mirrored, never substituted: the server check remains the authority.
- **"Your standing" card in Profile** for everyone, not just verifiers — the point of a ladder is that the path is visible. Thresholds come from `trust_thresholds()` with the counts, so the progress bar can never disagree with the rules the user is judged by.
- **14 new pgTAP negatives (39 total), and I checked they have teeth**: removing the "cannot create facilities" and "cannot self-approve" guards turns exactly those two assertions red.
- 135 tests green (+12); analyze + custom_lint clean.

**Needs the user:** apply `supabase/migrations/20260727000003_trust.sql` in the Supabase SQL editor. Until then the app falls back to `TrustStanding.unknown` (reads as "new"), which is why the card is informational and never blocking.

**Next:** corroboration auto-verify — N independent agreeing reports publish without any admin — which is the other half of the bottleneck fix. Then the hardware-blocked items: two-device E2E chat smoke test, TalkBack/VoiceOver sweep, TLS pin bundle, production tile provider (ADR-13).
---
## Session 17 — 2026-07-27 · E5 closed (audit log + batch approve) · E6 closed (critical-alert signals)
**Done:**
- **Audit-log viewer** — `features/verify/presentation/audit_log_screen.dart`, reached from an `Icons.history` action in the queue AppBar. The backend has written an append-only `audit_log` since ADR-14, but nothing in the app could read it, so verify-before-display had accountability on paper only. Read-only by design: `audit_log` has no update or delete policy at all, and putting edit affordances on the screen would imply otherwise. The append-only promise is stated in the UI, not just in the schema. Demo Mode serves five sample entries so it is explorable with no backend.
- **Batch approve** — opt-in select mode, off by default. While it is on, the per-card approve/reject buttons are **hidden**: mixing a one-tap publish into a multi-select list is how the wrong thing reaches the public map. Confirmation states the count. The RPCs run **sequentially**, so each gets its own server-side authz check, and the result is reported as done/failed counts — a partial failure says "3 approved, 1 failed", never a blanket "done".
- **Edit-before-approve deliberately NOT built** and logged as such: it needs a new RPC parameter and a migration, and reject-with-reason already covers "this is wrong". Left ticked open in PROJECT_MANAGEMENT.md rather than quietly dropped.
- **Critical-alert sound/vibration (ADR-24)** — the last E6 item, and it needed **no plugin**: `HapticFeedback` + `SystemSound` from `flutter/services`, so no permission prompt, no notification channel, nothing added to the manifest. The design decision is the asymmetry: **vibration on by default, sound off by default**. A pocketed phone can buzz without telling anyone nearby that its owner gets protest alerts; a phone that chimes unexpectedly in a kettle or a police line identifies the person holding it. That is the user's risk to accept, so it is opt-in. Both toggles live in Profile and persist.
- Fires **once per alert id**, not once per rebuild: a re-sync, an edit to the same alert, or a widget rebuild stays silent, and switching sound on later does not retroactively buzz for what is already on screen.
- 123 tests green (+13); analyze + custom_lint clean; web build green.

**Test note:** the "a new critical alert signals again" test failed at first for a reason worth keeping — Drift stores `DateTime` at **second** precision, so two alerts inserted 100 ms apart tie on `created_at` and the feed ordering never changes. Tests that depend on alert ordering must space the timestamps explicitly.

**Next:** Phase 4 — trust scores and promotion rules, so verification stops being a single-admin bottleneck. Still hardware-blocked and unchanged: two-device E2E chat smoke test, TalkBack/VoiceOver sweep, TLS pin bundle from a trusted network, production tile provider (ADR-13).
---
## Session 16 — 2026-07-27 · E6 closed: admin authoring for public alerts
**Done:**
- **`ComposeAlertScreen`** — the missing half of E6. Until now nothing could create a verified public alert; the feed could only ever show seeded or synced ones.
- **Severity + body + mandatory expiry.** There is no "never expires" option on purpose: a stale warning is worse than no warning, and the screen says so.
- **Critical needs a second confirmation**, warn and info do not — friction on a warning is friction on getting information out, but a critical alert takes over the top of everyone's map.
- **States the asymmetry before you type**, not after you post: this is public and unencrypted, unlike a group broadcast (ADR-21). The two are visually similar and must never be confused.
- Local-first: writes to Drift so the feed and map banner update immediately, then pushes to Supabase (RLS already restricts `alerts` insert to admins — the negative tests assert a non-admin cannot).
- **Corrected a false claim in my own doc comment**: it said the alert was "queued in the outbox", which was not implemented. Alerts have no outbox retry yet, so the code now says exactly that and the UI reports "saved on this device, but NOT sent" rather than implying it reached anyone.
- 110 tests green (+5 covering the public warning, the expiry, and that cancelling the critical dialog writes nothing); analyze + custom_lint clean; web build green.

**Test note:** four of the new tests initially failed because the publish button sits below the fold in the 800×600 test viewport — `ensureVisible` before `tap`. Worth remembering for any long form.

**Next:** E5's remaining items — audit-log viewer and batch/merge approve actions — then Phase 4 (trust scores, promotion rules).
---
## Session 15 — 2026-07-27 · Nearby full-height, Groups create action, Directions/Share
**Done:**
- **Nearby sheet now opens fully.** It was capped at `maxChildSize: 0.5`, so half the screen was the hard ceiling — the reported bug, not a gesture problem. Now three snap points (16% / 50% / 94%) and the tappable header cycles through them, which matters because flutter_map's pan gestures fight a drag started over the map. Stops at 94% deliberately: a sliver of map keeps the sheet visibly dismissible.
- **Create group was invisible, and it was a real layout bug.** `HomeShell` uses `extendBody: true` for the glass nav bar, so a FAB in a nested Scaffold renders *underneath* it. Added the requested top-right action AND lifted the FAB by 72dp so both work.
- **Directions and Share shipped** (were stubs showing "arrives in a later build"). Directions hands off via the platform `geo:` scheme so the user's own map app wins — deliberately not a hardcoded Google Maps URL (ADR-7, and the destination is exactly what shouldn't be routed through a third party by default); OpenStreetMap is the fallback and the web path. Share sends public facility info only — name, status, coordinates — never who reported it, and falls back to the clipboard where no share sheet exists.
- 105 tests green; analyze + custom_lint clean; web build green.

**Next:** admin authoring for *public* alerts (completes E6), audit-log viewer and batch actions (completes E5), then Phase 4 (trust scores, promotion rules).
---
## Session 14 — 2026-07-26 · "Complete everything": broadcasts, QR scan, Phase-2 hardening, real test gates
**Done:**
- **Group broadcasts (ADR-21)** — reuse the alerts *presentation*, never the public alerts table (that would make group content server-readable and fetchable by non-members). The broadcast flag lives inside the ciphertext, so the server can't distinguish announcements from chatter. Untagged text stays a plain message → no migration, existing chat decodes unchanged. A test proves a user can't type a string that fakes one.
- **QR scanning** (`mobile_scanner`) — `inviteCodeFrom()` treats scanned content as attacker input; only a well-formed 8-char code reaches `joinByCode`. Falls back to code-paste on web / no camera / denied permission.
- **Panic wipe** — keys deleted FIRST so a wipe killed halfway still fails safe, then every table, then local sign-out. The dialog says what it cannot reach (the server, other devices).
- **Cert pinning** — mechanism complete and fails closed, but shipped INACTIVE. This container's egress proxy terminates TLS, so any pin I derived here would have pinned Anthropic's sandbox CA. Added `tool/fetch_api_roots.sh` (refuses interception chains) + the procedure. A guessed pin is worse than none.
- **EXIF stripping** — decode+re-encode, so thumbnails/maker notes/XMP can't survive; orientation baked in first. A test caught that `decodeImage` *throws* on malformed input rather than returning null — "fails closed" wasn't actually true until I fixed it.
- **App icon + applicationId** — `io.github.prajwalpatilhub.commonground` (a namespace the owner actually controls). Icon: two overlapping saffron circles, intersection filled — abstract on purpose, since a recognisable symbol on a protester's home screen is itself a risk.

**Three things that were only *claimed* before, and are now actually true:**
- **Migration tests found a real bug.** The v2 step called `createTable` but never created the table's index, so every *upgraded* install lost the chat index and would full-scan on each 3s poll — on exactly the low-end devices we target. Fresh installs were fine, which is why nothing surfaced it.
- **The RLS negatives had never been executed.** They now run in CI against a plain Postgres (shim, no Docker). All 25 pass — and I verified the suite *fails* when `messages_member_read` is weakened to `using (true)`. A suite that has only ever been green proves nothing.
- **The CVD audit was a recurring ritual nobody ran.** Automated it; it found three genuine contrast failures. Fixed `unverified` (2.61:1 → 6.04:1). Two are accepted and **pinned, not waived**: `low` amber (1.92:1 — every compliant darker amber collapses against red under CVD, and Low-vs-Out is the map's most consequential distinction) and `good`-vs-`out` under protanopia (the only in-family fix makes "good" a teal that collides with info blue). Both are carried by the standing icon+text rule. The test also asserts the saffron accent is indistinguishable from status colours under CVD, giving ADR-10's "never use accent for status" ban teeth.

**100 tests green; analyze + custom_lint clean; web build green.**

**Honest gaps — all need hardware or a trusted network, none are code:** two-device E2E chat smoke test; TalkBack/VoiceOver sweep (checklist in `docs/accessibility-audit.md`, and the SOS hold-to-fire gesture is the one I'd expect trouble on); the TLS pin bundle; a production tile provider (ADR-13). Also: broadcasts are not push notifications — a member sees one when they next open the app.
---
## Session 13 — 2026-07-26 · Offline group chat (ADR-19): local ciphertext cache + outgoing queue
**Done:**
- **Drift schema v2** — `CachedGroupMessages(id, group_id, sender_id, ciphertext, pending, created_at)` + index, with a real `MigrationStrategy` (v1 installs get the table on upgrade, no data loss). First migration this project has needed.
- **Ciphertext only, never plaintext.** The cache holds exactly what the server holds; the group key stays in the OS keystore. A seized device with a dumped SQLite file yields nothing, and wiping the keys makes the cache permanently unreadable — `GroupMessageCache.wipe()` is ready for the panic-wipe path. Caching plaintext would have handed away everything the E2E work exists to protect (ADR-19).
- **Local-first reads.** `GroupsRepo.cachedMessages()` (new, no network) paints the conversation before any request; `messages()` refreshes, upserts the cache, and rebuilds through the same code path so cached and live reads cannot drift apart. `_groupKey` was split so the offline path can never touch the network.
- **Visible degraded state**, not a silent failure or an empty chat: a refresh failure shows "Offline — showing saved messages" (cloud-off icon + text, bilingual) while the cached chat stays fully readable.
- **Offline sends queue.** `sendMessage` encrypts on-device, persists with `pending = true`, then tries to push; no signal is *not* an error — the bubble shows "Sending…" (clock icon + text). The queue drains oldest-first and stops at the first failure, so message order can never break; an acked message is swapped for the server's copy in one transaction so it never blinks out of the list.
- Demo repo implements `cachedMessages` too, so demo and real modes behave identically.
- 57 tests green (+6: cache upsert/scoping/ordering, ciphertext-only, pending→acked lifecycle, clear/wipe, plus two widget tests that pump the real chat against a no-network repo and assert the offline banner and the queued "Sending…" bubble). analyze + custom_lint clean; web build green.

**Honest gaps:** the v1→v2 migration is written and reviewed but not exercised by a drift schema-migration test (that needs generated schema snapshots — worth adding before the next schema change). Chat is still poll-based, not Realtime. Nothing calls `wipe()` yet because panic-wipe itself is still unbuilt.

**Next:** key rotation on member removal, group broadcast reusing the alerts pipeline, QR scanning on device, RLS tests in CI.

### Same session, part 2 — key rotation on member removal (ADR-20)
**Done:**
- **Drift v3**: `key_epoch` on the chat cache (additive migration, exercises the strategy added an hour earlier).
- **Rotation**: admin Remove → the member row is deleted *first* (rotating while they're still a member would just hand them the new key) → a new random key at `epoch+1` is sealed to every remaining **active** member → cached locally.
- **All epochs kept.** Keystore now indexes epochs per group (`group_key_epochs_<id>`), with a compat shim for the pre-rotation single-key location. Each message carries its epoch, so rotation gives forward secrecy *without* wiping readable history — the mistake that would have made this feature actively harmful.
- **Offline-queued messages are re-sealed** under the current epoch before they go out, closing the window where a just-removed member could read something typed a minute before their removal.
- `approveMember` now seals the *current* epoch, not a hardcoded `1` — a new member gets today's key, never the history predating them.
- Honest UI: the confirm dialog states that they lose access and a new key is issued, **and** that messages already on their device stay there. If any remaining member has no published device key, `removeMember` returns that count and the UI warns rather than letting them silently go dark.
- Fixed a bad first attempt: I inferred "is this me" from the admin flag, which would have blocked an admin from removing another admin. Replaced with an explicit `GroupMember.isMe` set by the repository (the only layer that knows the signed-in id).
- **+3 pgTAP negatives → 15 group RLS assertions**: a non-admin cannot issue key envelopes (cannot rotate), cannot remove another member, and a removed member can no longer read the ciphertext at all.
- 62 tests green (+5: three crypto-level rotation properties — removed member cannot read post-rotation messages or open the new envelope, old epochs stay readable, re-sealing works — plus demo removal and the isMe invariant). analyze + custom_lint clean; web build green.

**Honest gaps:** rotation is forward-secrecy only, by construction. Neither migration (v1→v2, v2→v3) is covered by a drift schema-migration test — that needs generated schema snapshots and should land before the next schema change. The 15 RLS assertions are still written-but-not-run (needs `supabase start && supabase test db`).
---
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
