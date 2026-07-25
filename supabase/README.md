# CommonGround backend (Supabase)

Project: `https://orsqjucexvrefmexztay.supabase.co` (Mumbai, ADR-8).
Everything privileged lives here — the app ships only the public URL +
publishable key.

## One-time setup (dashboard) — DO THESE NOW

1. **Apply the schema:** Dashboard → SQL Editor → paste the full contents of
   `migrations/20260724000001_init.sql` → Run, then do the same with
   `migrations/20260725000002_groups.sql` (groups + E2E chat). Apply them in
   filename order. (Or `supabase db push` with the CLI if you link the project.)
2. **Enable anonymous sign-ins:** Dashboard → Authentication → Sign In /
   Up → enable **Anonymous sign-ins** (ADR-4: anonymous-by-default; the app
   signs in anonymously in the background).
3. **Create your admin account:** Dashboard → Authentication → Users →
   Add user → email + password (this is your verifier login in the app).
   Then make it admin — SQL Editor:
   ```sql
   update auth.users
     set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb)
         || '{"role":"admin"}'::jsonb
   where email = 'YOUR_EMAIL_HERE';
   ```
   Roles live in `app_metadata` because clients can never write it
   (SECURITY.md). Sign out/in in the app after changing the role.

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
