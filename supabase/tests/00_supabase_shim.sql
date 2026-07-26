-- Minimal stand-ins for the Supabase-managed objects our migrations and RLS
-- policies depend on, so the negative tests can run against a plain Postgres
-- (CI, or `psql` locally) instead of only inside `supabase start`.
--
-- This shim recreates only what the policies actually read:
--   * the `authenticated` / `anon` roles
--   * `auth.users`
--   * `auth.uid()` and `auth.jwt()`, resolved from `request.jwt.claims`
--
-- It is NOT loaded by `supabase test db`, which supplies the real objects —
-- guard clauses make it a no-op there. If a policy ever depends on Supabase
-- behaviour this shim does not reproduce, the test would pass here and fail in
-- production, so keep the shim honest and keep running the real thing too.

do $$
begin
  if not exists (select 1 from pg_roles where rolname = 'authenticated') then
    create role authenticated nologin;
  end if;
  if not exists (select 1 from pg_roles where rolname = 'anon') then
    create role anon nologin;
  end if;
  if not exists (select 1 from pg_roles where rolname = 'service_role') then
    create role service_role nologin;
  end if;
end
$$;

create schema if not exists auth;
create schema if not exists extensions;
create extension if not exists pgcrypto with schema extensions;
create extension if not exists pgtap;

create table if not exists auth.users (
  id uuid primary key,
  aud text,
  role text,
  email text
);

-- Supabase resolves these from the request's JWT claims; `set local
-- request.jwt.claims` in a test is exactly how the real thing is driven too.
create or replace function auth.uid() returns uuid
language sql stable as $$
  select nullif(
    current_setting('request.jwt.claims', true)::json ->> 'sub', ''
  )::uuid;
$$;

create or replace function auth.jwt() returns jsonb
language sql stable as $$
  select coalesce(
    nullif(current_setting('request.jwt.claims', true), '')::jsonb,
    '{}'::jsonb
  );
$$;

grant usage on schema auth, public, extensions to authenticated, anon;

-- Supabase ships default privileges that grant `anon`/`authenticated` table
-- access, with RLS — not GRANTs — doing the actual gating. Our migrations
-- assume that and issue no GRANTs of their own, so reproduce it here or every
-- policy test fails with "permission denied" before RLS is ever consulted.
--
-- NOTE for self-hosting (ADR-8's escape hatch): a plain Postgres has none of
-- this, so a self-hosted deployment must apply equivalent grants. Tracked in
-- supabase/README.md.
alter default privileges in schema public
  grant all on tables to anon, authenticated, service_role;
alter default privileges in schema public
  grant all on sequences to anon, authenticated, service_role;
alter default privileges in schema public
  grant all on functions to anon, authenticated, service_role;
grant all on all tables in schema public to anon, authenticated, service_role;
grant select on auth.users to authenticated;
