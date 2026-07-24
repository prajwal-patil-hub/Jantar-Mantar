# Group-Based Architecture — Research & Design Report
_Research report · 2026-07-24 · Reference for Phase 3 (groups) + security/legal_

## TL;DR
- **Layered model confirmed; ship groups in Stage 1 (Phase 3), not MVP.** MVP proves the public verified map first. Borrow WhatsApp/Telegram/Discord invite mechanics (time + max-use expiry, revocation, approval queues), Signal-style minimal server-side membership visibility, Reddit's federated-moderation-with-sitewide-rules.
- **Privacy is the architecture:** opaque user-ID invites over phone numbers; minimal membership visibility; hidden groups default; panic "hide my membership."
- **Group admin is a legal target — design for detention/succession.** Indian case law shields admins absent "common intention," but the app operator is an intermediary under IT Rules 2021 (Section 79 safe harbour requires due-diligence).

## Key findings
1. **Invite mechanics are standardized — copy them.** Telegram: one link can carry expiry (1h/1d/1w/custom) + usage cap + admin-approval requirement, all combinable; instant revocation. Discord: "Expires After" (30 min–7 days) + "Max Uses"; audit log shows join source; 5 verification levels (None→email→5-min account age→10-min membership→verified phone) to blunt leaked-link spam.
2. **Invite links WILL leak.** Feb 2020: ~470k WhatsApp group invite links indexed by Google (`site:chat.whatsapp.com`); recurred Jan 2021. Design as if every link is public → mandatory approval queue after link/QR join; `noindex` + robots.txt on all link pages.
3. **Signal proves the server needn't know membership.** Private Group System: encrypted membership lists + anonymous credentials; server stores no group titles/avatars/membership. Private contact discovery + usernames (2024) = gold standard for add-by-ID. (Caveat: Groups V2 partly rests on trust-Signal-not-logging; full anonymous credentials are a large build — treat "minimal visibility" as design target.)
4. **Federated moderation:** Reddit model = communities self-moderate under sitewide rules enforced by platform admins who can remove/replace abusive communities. Waze editor levels (auto-promote low levels by correct-edit counts; grant high levels) gate sensitive edits. OSM: changeset review (OSMCha), suspicious feeds, revert tooling. Community Notes' bridging (diverse-rater agreement) is manipulation-resistant but gameable with synthetic diverse voting; >90% of notes never publish — never rely on group consensus alone.
5. **Firebase Dynamic Links shut down Aug 25, 2025.** Use native App Links (assetlinks.json) + Universal Links (apple-app-site-association). Avoid Branch/AppsFlyer etc. (tracking). Flutter QR: `mobile_scanner` + `qr_flutter`; `qr_code_scanner` unmaintained.
6. **Police infiltration is documented:** Noida 2025 (UP police SI + informer inside "Richa Global" WhatsApp group; admins arrested), Israel 2020 (≥10 officers in anti-Netanyahu WhatsApp groups), Hong Kong 2019 (Telegram admin Ivan Ip arrested; police forced export of 20–30k member list from his phone). Threat model: any joinable group contains hostile actors.
7. **India legal:** group admins not vicariously liable absent "common intention" (Bombay HC *Kishor Tarone*, Delhi HC *Ashish Bhalla*, etc.). Operator = "intermediary"/"social media intermediary" under IT Rules 2021 → Rule 3 due-diligence or lose Section 79 safe harbour.

## Layered data model
- **Public-layer facilities are canonical; groups annotate/propose, never own copies** (OSM/Wikipedia model — prevents fragmented duplicates).
- **Promotion (group-verified → public):** never auto on group trust alone. Two-key: auto-publish if trusted group AND ≥1 independent corroboration (second group / platform moderator / N public confirmations); else platform-moderator queue.
- **Group trust score:** accepted-vs-reverted promotion history + age + independent corroboration; new groups untrusted.
- **Conflicts:** canonical entity shows freshest verified state; per-group annotation history stays visible ("Group A: food 200, 2h ago · Group B: depleted, 20m ago").
- **Pollution defense:** trust threshold + corroboration + moderator suspend + revert tooling + preserved history.
- **Group-private pins** (meeting points, member locations, supplies): group-scoped, never promotable, enforced at DB layer (RLS), not just UI.

## Invite & access security
- Every invite: time expiry AND max-uses (default short: 24h, small cap). Revocation + rotation. Show admins join source.
- **Approval queue after link/QR join is mandatory** (links leak).
- **Offline QR join:** signed offline token (Ed25519: group ID, expiry, uses seed, nonce) validated against cached group pubkey → provisional local admit → reconciled to server + retroactive approval queue on sync. Pair with CRDT sync.
- **Add-by-user-ID strongly preferred over phone number.** Contact discovery reveals who uses the app; a protest group + telecom-traceable number is a liability. If phone adding exists: mutual opt-in only, numbers never exposed to members.
- Deep links: native App Links/Universal Links; all web fallbacks `noindex`.

## Roles & permissions
- In-group: **Group Admin** (owner: settings, visibility, joins, roles, ban, broadcast, promotion requests, transfer, successors) → **Co-admin/Moderator** (verify, members, invite, broadcast; can't delete group/change owner) → **Verified member** (submit + verify in-group) → **Member** (view, submit unverified, receive alerts).
- Site-level: **Platform Moderators** — promotion review, suspend abusive groups, sitewide rules override group rules.
- **Emergency succession:** admin pre-designates ranked successors; inactivity window or panic trigger auto-promotes. (Ivan Ip scenario.)
- Implementation: Supabase Postgres RLS — memberships(user_id, group_id, role) + deny-by-default policies on every group-scoped row; SECURITY DEFINER helpers; indexed policy columns; roles in JWT app_metadata (server-set, never client-writable); column grants. Firebase alt: custom claims + Firestore rules. Automated negative tests ("member of A cannot read B's pins").

## Group UX (key screens)
- **Discovery:** public groups near site with member counts + NGO-verified badges + Request-to-join; hidden groups unlisted; "Have a link or QR? Scan/Paste."
- **Create-group:** name, template picker (Medical/Food/Legal/Safety/Custom), visibility Public/Hidden (default hidden), join-method toggles (QR/link/add-by-ID; phone discouraged), link expiry + max, approval always/off (default always).
- **Group home:** map layer toggles [Public ✔][My group ✔]; announcement banner; tabs Map/Alerts/Members/More.
- **Join flow:** shows managing admin, "request reviewed before you see group pins," per-group display name, caution note.
- **Manage members:** requests queue (source shown: via QR/link) approve/deny; admins list; remove/ban; Emergency succession settings.
- **Multi-group:** overlay checkboxes per group + public layer → Apply.

## Risks & mitigations
- **Infiltration** → hidden default, mandatory approval, opaque IDs, small vetted groups, NGO badges.
- **Admin legal exposure** → succession, minimal server-visible data (seizure/subpoena yields little).
- **Operator liability (IT Rules 2021):** publish rules + privacy policy (Rule 3(1)(a)); Grievance Officer — ack 24h, resolve 15 days, most takedown requests 72h (Rule 3(2)(a)); remove court/govt-flagged content within 36h (Rule 3(1)(d)); info/assist authorities within 72h (Rule 3(1)(j)); preserve removed content 180 days; else Section 79 safe harbour lost (Rule 7). SSMI threshold 50 lakh (5M) Indian users → CCO, 24×7 Nodal Person, Resident GO, monthly reports (Rule 4); traceability (Rule 4(2)) applies to messaging-primary services. **Rule 6 lets MeitY impose SSMI-grade duties on ANY intermediary posing "material risk of harm to public order" — a protest app is plausibly exposed below the threshold.** Nov 2025 amendment: takedown intimations require Joint-Secretary-level officer, written reasons, Secretary-level monthly review. (Some 2026 sources mention tighter 2–3h windows — verify against MeitY gazette before launch.)
- **Metadata exposure** → membership is sensitive; store minimum; encrypt where feasible.
- **Offline sync conflicts** → CRDTs: counters for capacity, LWW-register + vector clocks for pins, add-wins set for membership reconciled with approval queue.
- **Lifecycle** → dormant groups auto-archive (read-only → purge private pins).

## Improvement ideas (beyond user's spec)
1. Group templates (medical/food/legal/safety) with safe defaults.
2. Inter-group announcement bus (WhatsApp Communities pattern) without merging membership.
3. Platform-issued verification badges (NGO-verified / known-organizer).
4. Resource pledging between groups ("50 water bottles to Gate 3") surfacing as public pending pledges.
5. First-class succession planning.
6. Panic feature: one tap hides memberships + private pins locally and suppresses server-side visibility (duress mode).
7. Ephemeral group pins with short TTLs (seized device reveals little).

## Roadmap integration
- **Groups = Stage 1 (Phase 3).** Minimal first set: create; hidden/public; QR + link invites (expiry + max-uses); mandatory approval; add-by-user-ID; admin + member roles; RLS-enforced private pins; layer toggle; group broadcast; trust-score stub; moderator suspend power.
- **Stage 2:** co-admin/verified-member granularity, promotion auto-rules, inter-group channels, pledging, badges, CRDT hardening.
- **Entity sketch:**
```
User(id, anon_handle, opt_phone_hash?, created_at)
Group(id, name, template, visibility, join_methods[], trust_score,
      status[active|dormant|archived|suspended], created_by)
Membership(user_id, group_id, role, joined_via, state[pending|active|banned], display_name)
Invite(id, group_id, type[qr|link], token_signed, expires_at, max_uses, uses, revoked, created_by)
Facility(id, geo, type, capacity, canonical=true, state)
GroupAnnotation(id, facility_id, group_id, capacity, note, verified_by, ts)
GroupPin(id, group_id, geo, type[meeting|member|supply], ttl, promotable=false)
PromotionRequest(id, group_id, facility_id|annotation_id, corroboration_count, status, reviewed_by)
Succession(group_id, ordered_successor_user_ids[], trigger_config)
```

## Benchmarks that change recommendations
- Captured group pollutes public map → raise corroboration threshold; moderator review for ALL promotions.
- Rule 6 order or ~5M Indian users → stand up SSMI compliance immediately.
- Shutdown breaks group sync in the field → pull CRDT + signed-offline-token invites forward to Stage 1.
- Infiltration detected → invite-only + vouching, shrink max group size, small-vetted-group templates.

## Caveats
- Signal-grade membership privacy = large build; "minimal visibility" is a target, not a claim.
- Bridgefy is NOT a safe offline-messaging reference (broken 2020/2022 analyses).
- Community-Notes-style consensus is gameable; require independent corroboration.
- IT Rules citations compiled from MeitY consolidated text + law-firm analyses — re-verify rule numbers and 2025/2026 amendments against latest gazette before compliance reliance.
