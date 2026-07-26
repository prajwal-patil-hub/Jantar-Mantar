# ARCHITECTURE.md
_Last updated: 2026-07-24_

## Stack (proposed — confirm in E1.1)
- **App:** Flutter (Material 3), Riverpod (state), feature-first folders
- **Local DB:** Drift (SQLite) — typed queries, good for relational sync queues
- **Map:** flutter_map + OpenStreetMap tiles + FMTC (offline tile caching) — no Google billing, offline-friendly
- **Backend:** Supabase (Postgres + RLS + Realtime + Auth) — deny-by-default RLS fits group scoping; self-hosting escape hatch for data-residency/privacy
- **Push:** FCM (alerts), degrade to in-app polling when unavailable
- **Deep links:** native App Links / Universal Links (Firebase Dynamic Links is dead). QR: mobile_scanner + qr_flutter

## High-level flow
```
┌─────────────┐   queued writes    ┌──────────────┐
│ Flutter app │ ─────────────────► │ Sync worker   │
│  UI layer   │                    │ (retry/backoff)│
│  Riverpod   │ ◄── local-first ── │               │
│  Repos      │      reads         └──────┬────────┘
│  Drift DB   │                           │ TLS + pinning
└─────────────┘                    ┌──────▼────────┐
      ▲                            │ Supabase       │
      │ cached tiles (FMTC)        │  Postgres+RLS  │
┌─────┴───────┐                    │  Auth (anon)   │
│ OSM tiles   │                    │  Realtime      │
└─────────────┘                    └────────────────┘
```

## Data model (MVP entities; group entities land Phase 3)
```
User(id, anon_handle, device_pubkey, trust_score, created_at)
Facility(id, geo, type, name, status[good|low|out|closed], canonical=true)
CapacityReading(facility_id, resource[water|food|shelter], for_people,
                verified_by?, verified_at?, expires_at)   -- TTL 30–60 min
Submission(id, facility_id?|new_geo, payload, photo?, submitter_id,
           state[pending|approved|rejected], reason?, created_at)
Alert(id, severity[info|warn|critical], area_geo?, body, created_by, expires_at)
AuditLog(id, actor_id, action, before, after, ts)          -- append-only
SyncQueue(local_id, op, entity, payload, state, attempts)  -- client-side
CachedGroupMessage(id, group_id, sender_id, ciphertext, key_epoch, pending,
                   created_at)                             -- client-side, v3
-- Phase 3: Group, Membership, Invite, GroupPin, PromotionRequest, Succession
```

Local schema is at **v3** (`app/lib/core/db/app_database.dart`); v2 added
`CachedGroupMessages`, v3 added `key_epoch`. It stores **ciphertext only** —
group keys live in the OS keystore, so the SQLite file is worthless on a
seized device and a panic-wipe of the keys makes the cache permanently
unreadable. Rows flagged `pending` are messages encrypted on-device but not
yet accepted by the server.

**Group-key epochs (ADR-20).** Removing a member mints a new group key at the
next epoch, sealed to everyone who remains. The device keeps every epoch it
has held (`group_key_epochs_<group>` indexes them in the keystore) and each
message carries the epoch it was sealed under, so rotation gives forward
secrecy without destroying readable history.

## Sync rules
1. Read: emit local immediately → refresh in background → update UI.
2. Write: save local as `pending` → optimistic UI → sync worker pushes with exponential backoff.
3. Conflict (MVP): server timestamp wins for capacity; submissions never conflict (append-only).
4. Freshness banding drives UI: <5m fresh · 5–30m judgment · >30m stale badge · >TTL auto-degrade.

## Verification pipeline (MVP)
submit → pending (visible only to submitter, dashed) → admin approve/reject(+reason)
→ approved = published + verified badge → CapacityReading TTL starts → expiry degrades → auto-archive.
