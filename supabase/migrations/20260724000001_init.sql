-- CommonGround initial schema (E5/E8).
-- Security model (SECURITY.md): RLS deny-by-default on every table; the
-- publishable key grants nothing by itself. All privileged writes go through
-- SECURITY DEFINER functions that check the admin role from JWT app_metadata
-- (server-set, never client-writable). Clients send client-generated ids for
-- idempotent sync retries.

-- ---------------------------------------------------------------- helpers

create or replace function public.is_admin()
returns boolean
language sql
stable
as $$
  select coalesce(
    (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin',
    false
  );
$$;

-- ------------------------------------------------------------------ tables

create table if not exists public.facilities (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 1 and 120),
  type text not null check (
    type in ('water','food','shelter','medical','toilet','safeArea','danger')
  ),
  status text not null check (status in ('good','low','out','closed')),
  lat double precision not null check (lat between -90 and 90),
  lng double precision not null check (lng between -180 and 180),
  canonical boolean not null default true,
  verified_at timestamptz,
  updated_at timestamptz not null default now()
);

create table if not exists public.capacity_readings (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities(id) on delete cascade,
  resource text not null check (resource in ('water','food','shelter')),
  for_people integer not null check (for_people between 0 and 1000000),
  verified_by uuid references auth.users(id),
  verified_at timestamptz,
  expires_at timestamptz not null,
  created_at timestamptz not null default now()
);
create index if not exists capacity_readings_facility_idx
  on public.capacity_readings(facility_id, created_at desc);

create table if not exists public.submissions (
  id uuid primary key default gen_random_uuid(),
  -- Client-generated id: makes offline sync retries idempotent.
  client_id text not null unique check (char_length(client_id) <= 64),
  -- Text reference (not FK): clients may reference facilities they only
  -- know locally; the admin decision function resolves it server-side.
  facility_ref text check (char_length(facility_ref) <= 64),
  lat double precision check (lat between -90 and 90),
  lng double precision check (lng between -180 and 180),
  payload jsonb not null,
  submitter_id uuid not null default auth.uid() references auth.users(id),
  state text not null default 'pending'
    check (state in ('pending','approved','rejected')),
  reason text check (char_length(reason) <= 500),
  created_at timestamptz not null default now()
);
create index if not exists submissions_pending_idx
  on public.submissions(state, created_at) where state = 'pending';

create table if not exists public.alerts (
  id uuid primary key default gen_random_uuid(),
  severity text not null check (severity in ('info','warn','critical')),
  body text not null check (char_length(body) between 1 and 500),
  lat double precision check (lat between -90 and 90),
  lng double precision check (lng between -180 and 180),
  radius_meters double precision check (radius_meters between 0 and 100000),
  created_by uuid not null default auth.uid() references auth.users(id),
  created_at timestamptz not null default now(),
  expires_at timestamptz not null
);

create table if not exists public.sos_signals (
  id uuid primary key default gen_random_uuid(),
  client_id text not null unique check (char_length(client_id) <= 64),
  fired_at timestamptz not null,
  created_by uuid not null default auth.uid() references auth.users(id),
  created_at timestamptz not null default now()
);

-- Append-only; writes happen inside SECURITY DEFINER functions only.
create table if not exists public.audit_log (
  id bigint generated always as identity primary key,
  actor_id uuid,
  action text not null,
  entity text,
  entity_id text,
  before jsonb,
  after jsonb,
  ts timestamptz not null default now()
);

-- --------------------------------------------------------------------- RLS
-- Enabling RLS with no policy = deny. Policies below are the ONLY access.

alter table public.facilities enable row level security;
alter table public.capacity_readings enable row level security;
alter table public.submissions enable row level security;
alter table public.alerts enable row level security;
alter table public.sos_signals enable row level security;
alter table public.audit_log enable row level security;

-- Public verified map: anyone (including signed-out) can read.
drop policy if exists facilities_read on public.facilities;
create policy facilities_read on public.facilities
  for select to anon, authenticated using (true);

drop policy if exists capacity_read on public.capacity_readings;
create policy capacity_read on public.capacity_readings
  for select to anon, authenticated using (true);

drop policy if exists alerts_read on public.alerts;
create policy alerts_read on public.alerts
  for select to anon, authenticated using (true);

-- Submissions: users insert their own pending rows and read only their own;
-- admins read all. State changes ONLY via the decision functions below.
drop policy if exists submissions_insert_own on public.submissions;
create policy submissions_insert_own on public.submissions
  for insert to authenticated
  with check (submitter_id = auth.uid() and state = 'pending');

drop policy if exists submissions_read_own on public.submissions;
create policy submissions_read_own on public.submissions
  for select to authenticated
  using (submitter_id = auth.uid() or public.is_admin());

-- Alerts: only admins broadcast.
drop policy if exists alerts_admin_insert on public.alerts;
create policy alerts_admin_insert on public.alerts
  for insert to authenticated
  with check (public.is_admin());

-- SOS: users file their own; only admins see them.
drop policy if exists sos_insert_own on public.sos_signals;
create policy sos_insert_own on public.sos_signals
  for insert to authenticated
  with check (created_by = auth.uid());

drop policy if exists sos_admin_read on public.sos_signals;
create policy sos_admin_read on public.sos_signals
  for select to authenticated
  using (public.is_admin());

-- Audit log: admins read; nobody writes directly (functions only).
drop policy if exists audit_admin_read on public.audit_log;
create policy audit_admin_read on public.audit_log
  for select to authenticated
  using (public.is_admin());

-- --------------------------------------------- admin decision functions
-- SECURITY DEFINER so they can write across tables; each one re-checks
-- is_admin() — never trust the caller.

create or replace function public.approve_submission(
  p_submission_id uuid,
  p_mark_verified boolean default true,
  p_capacity_ttl_minutes integer default 45
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  sub public.submissions%rowtype;
  target_facility uuid;
  v_category text;
  v_status text;
  v_for_people integer;
begin
  if not public.is_admin() then
    raise exception 'admin role required';
  end if;

  select * into sub from public.submissions
    where id = p_submission_id and state = 'pending'
    for update;
  if not found then
    raise exception 'pending submission not found';
  end if;

  v_category := sub.payload ->> 'category';
  v_status := coalesce(sub.payload ->> 'status', 'good');
  v_for_people := (sub.payload ->> 'forPeople')::integer;

  -- Resolve the referenced facility if the client sent a valid uuid.
  if sub.facility_ref is not null then
    begin
      select id into target_facility from public.facilities
        where id = sub.facility_ref::uuid;
    exception when invalid_text_representation then
      target_facility := null;
    end;
  end if;

  if target_facility is null then
    insert into public.facilities (name, type, status, lat, lng, verified_at)
    values (
      coalesce(
        nullif(sub.payload ->> 'name', ''),
        initcap(v_category) || ' (reported)'
      ),
      v_category,
      v_status,
      sub.lat,
      sub.lng,
      case when p_mark_verified then now() end
    )
    returning id into target_facility;
  else
    update public.facilities
      set status = v_status,
          verified_at = case when p_mark_verified then now()
                             else verified_at end,
          updated_at = now()
      where id = target_facility;
  end if;

  if v_for_people is not null and v_category in ('water','food','shelter') then
    insert into public.capacity_readings
      (facility_id, resource, for_people, verified_by, verified_at, expires_at)
    values (
      target_facility,
      v_category,
      v_for_people,
      auth.uid(),
      case when p_mark_verified then now() end,
      now() + make_interval(mins => p_capacity_ttl_minutes)
    );
  end if;

  update public.submissions
    set state = 'approved'
    where id = p_submission_id;

  insert into public.audit_log (actor_id, action, entity, entity_id, before, after)
  values (
    auth.uid(), 'approve_submission', 'submission', p_submission_id::text,
    jsonb_build_object('state', 'pending'),
    jsonb_build_object('state', 'approved', 'facility_id', target_facility)
  );
end;
$$;

create or replace function public.reject_submission(
  p_submission_id uuid,
  p_reason text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception 'admin role required';
  end if;
  if p_reason is null or char_length(trim(p_reason)) = 0 then
    raise exception 'reason required';
  end if;

  update public.submissions
    set state = 'rejected', reason = p_reason
    where id = p_submission_id and state = 'pending';
  if not found then
    raise exception 'pending submission not found';
  end if;

  insert into public.audit_log (actor_id, action, entity, entity_id, before, after)
  values (
    auth.uid(), 'reject_submission', 'submission', p_submission_id::text,
    jsonb_build_object('state', 'pending'),
    jsonb_build_object('state', 'rejected', 'reason', p_reason)
  );
end;
$$;

-- Only signed-in users may call the decision functions (they re-check admin).
revoke execute on function public.approve_submission from public, anon;
revoke execute on function public.reject_submission from public, anon;
grant execute on function public.approve_submission to authenticated;
grant execute on function public.reject_submission to authenticated;
