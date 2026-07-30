# CommonGround backend (Supabase)

Project: `https://orsqjucexvrefmexztay.supabase.co` (Mumbai, ADR-8).
Everything privileged lives here — the app ships only the public URL +
publishable key.

## Applying migrations

### The short way — one paste (works on a phone)

`supabase/apply_all.sql` is every migration concatenated in order, and **it is
safe to run more than once**. Every statement is `create ... if not exists`,
`drop ... if exists` or `create or replace`, so it does not matter which
migrations your project already has — running it on a fully migrated project
changes nothing. Verified by applying it three times in a row to the same
database.

On an iPhone:

1. Open the raw file and copy all of it:
   `https://raw.githubusercontent.com/prajwal-patil-hub/Jantar-Mantar/main/supabase/apply_all.sql`
   → tap and hold → **Select All** → **Copy**. (Use the *raw* URL. GitHub's
   normal file view adds line numbers to the copied text, which will not run.)
2. `supabase.com/dashboard` → your project → **SQL Editor** → **New query**.
3. Paste → **Run**.
4. New query → paste `supabase/status.sql` → **Run**. Every column must read
   `t`.

The editor is usable on a phone in landscape. It is a big paste, so give it a
few seconds. If it stops partway, fix the error it names and run the whole
thing again — that is exactly what the idempotency is for.

`apply_all.sql` is **generated** by `supabase/build_apply_all.sh`. The
migrations remain the single source of truth; regenerate after adding one, or
the two will drift apart.

### The careful way — one migration at a time

Prefer this on a laptop, or when something has already gone wrong and you want
to see exactly which step fails.

### Step 0 — find out what is already applied

Dashboard → **SQL Editor** → **New query** → paste the contents of
`supabase/status.sql` → **Run**. You get one row of true/false:

```
 1_init | 2_groups | 3_trust | 4_corroboration | 5_moderation | 6_signing_keys | 7_join_hardening
--------+----------+---------+-----------------+--------------+----------------+------------------
 t      | t        | f       | f               | f            | f              | f
```

Run only the `false` ones. Never guess from memory — this checks for the
object each migration actually creates, so it cannot drift.

### Step 1 — run the missing migrations, in filename order

Order is not cosmetic: `4_corroboration` reads the `user_trust` table that
`3_trust` creates, and `5_moderation` alters it.

| # | File | Creates |
|---|---|---|
| 1 | `migrations/20260724000001_init.sql` | facilities, capacity, submissions, alerts, SOS, audit log, approve/reject RPCs |
| 2 | `migrations/20260725000002_groups.sql` | groups, members, device keys, sealed key envelopes, invites, group pins, messages |
| 3 | `migrations/20260727000003_trust.sql` | `user_trust`, tiers, `my_trust()`, verifier-aware `approve_submission` |
| 4 | `migrations/20260727000004_corroboration.sql` | auto-verify trigger (needs #3) |
| 5 | `migrations/20260728000005_moderation.sql` | `revoke_verifier`, `restore_trust`, `reporter_history` (alters #3's table) |
| 6 | `migrations/20260728000006_signing_keys.sql` | `device_keys.signing_public_key` for Ed25519 sender signatures |
| 7 | `migrations/20260730000007_join_hardening.sql` | **Security fix (ADR-36)** — removes the client self-join policy, adds `join_by_invite()` and the creator trigger |

For each one: SQL Editor → New query → paste the **whole file** → Run. Paste
the entire file, never a fragment — several of these contain `$$`-quoted
function bodies that break if split.

### Step 2 — check it took

Re-run `supabase/status.sql`. Every column should now read `t`.

### If something goes wrong

- **"already exists" on 1 or 2** — they are already applied. Skip them;
  do not re-run. (Migrations **3–6 are safe to run twice**; 1 and 2 are not.)
- **"relation public.user_trust does not exist" on 4 or 5** — you skipped 3.
  Run 3 first.
- **`42601: unterminated dollar-quoted string`** — a partial paste. Copy the
  file again from the top.
- **A migration failed halfway** — 3–6 are re-runnable, so fix the cause and
  run the whole file again. Postgres runs each statement in its own
  transaction here, so a later failure does not undo earlier statements.

### Verify with real behaviour, not just the schema

The local suite proves the policies do what they claim
(`./supabase/tests/run_local.sh`, 64 assertions). On the live project, the
quickest end-to-end check is: open the app → Profile → turn **Demo mode off**
→ Profile shows "New reporter" instead of an error, which means `my_trust()`
is reachable and #3 landed.

## Other one-time dashboard setup

1. **Enable anonymous sign-ins:** Authentication → Sign In / Up → enable
   **Anonymous sign-ins** (ADR-4: anonymous-by-default; the app signs in
   anonymously in the background). Without this the app stays in local-only
   mode however many migrations are applied.
2. **Create your admin account:** Authentication → Users → Add user → email +
   password (this is your verifier login in the app). Then make it admin —
   SQL Editor:
   ```sql
   update auth.users
     set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb)
         || '{"role":"admin"}'::jsonb
   where email = 'YOUR_EMAIL_HERE';
   ```
   Roles live in `app_metadata` because clients can never write it
   (SECURITY.md). Sign out and back in in the app after changing the role.

## Security model

- RLS **deny-by-default** on every table; the policies in the migration are
  the only access paths.
- Approve/reject go through `SECURITY DEFINER` functions that re-check
  `is_admin()` server-side and write the append-only `audit_log`.
- Clients send `client_id` (their local UUID) so offline sync retries are
  idempotent (unique constraint = second insert fails harmlessly).
- Negative tests: `tests/rls_negative_test.sql` (pgTAP). Run locally with
  `supabase start && supabase test db`. CI job to follow once the CLI is in
  the pipeline.

## Not yet migrated

- Photo storage + EXIF stripping (edge function) — deferred with photo
  capture.
- Push notifications (FCM) — later; alerts arrive via pull/Realtime for now.
- Rate limiting at the edge — before public launch.

## Running the RLS negative tests

```bash
./supabase/tests/run_local.sh            # plain Postgres + shim (what CI runs)
supabase start && supabase test db       # higher fidelity, needs Docker
```

`tests/00_supabase_shim.sql` stands in for the Supabase-managed objects the
policies read (`auth.users`, `auth.uid()`, the `authenticated` role) so the
suite runs without Docker. It also reproduces Supabase's **default table
grants**, which our migrations rely on implicitly.

**Self-hosting note (ADR-8's escape hatch):** a plain Postgres has none of
those default grants, so `anon`/`authenticated` would hit "permission denied"
before RLS was ever consulted. A self-hosted deployment must apply the
equivalent grants — see the shim for the exact statements.
