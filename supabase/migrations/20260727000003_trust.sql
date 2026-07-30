-- Phase 4 — trust scores and promotion rules (ADR-25).
--
-- The problem this solves is the top live risk in PROJECT_MANAGEMENT.md:
-- verification is a single-admin bottleneck, and during an actual protest a
-- queue that nobody drains is the same as no map at all.
--
-- The shape of the answer matters more than the numbers. A promoted
-- "verifier" is deliberately NOT a small admin:
--   * they can only approve UPDATES to facilities that already exist —
--     never create a new pin, so the worst case is a status flip on a known
--     facility, which the next report corrects;
--   * their approvals publish with verified_at = NULL, i.e. visible but not
--     admin-verified. This is exactly what ADR-2's two-axis model (publish
--     status ⊥ verified flag) was built for;
--   * they cannot decide their own submissions;
--   * they cannot REJECT anything. Rejection is admin-only on purpose: an
--     approval is self-correcting (the map keeps receiving reports), while a
--     rejection silently removes information from the queue, which is the
--     move a hostile verifier would make;
--   * they are rate-limited, so a compromised account cannot sweep the queue;
--   * every decision is in audit_log with the actor id, same as an admin's.
--
-- Trust is also REVERSIBLE. Counters recompute the tier on every decision, so
-- an account that builds standing and then starts posting garbage loses it
-- without an admin intervening.

-- ----------------------------------------------------------------- table

create table if not exists public.user_trust (
  user_id uuid primary key references auth.users(id) on delete cascade,
  approved_count integer not null default 0 check (approved_count >= 0),
  rejected_count integer not null default 0 check (rejected_count >= 0),
  tier text not null default 'new' check (tier in ('new','trusted','verifier')),
  promoted_at timestamptz,
  updated_at timestamptz not null default now()
);

-- Deny-by-default: RLS on, and the ONLY policy is a read of your own row
-- (plus admin read). There is no insert/update/delete policy anywhere, so
-- nobody can promote themselves — writes exist only inside the SECURITY
-- DEFINER functions below.
alter table public.user_trust enable row level security;

drop policy if exists trust_read_own on public.user_trust;
drop policy if exists trust_read_own on public.user_trust;
create policy trust_read_own on public.user_trust
  for select to authenticated
  using (user_id = auth.uid() or public.is_admin());

-- --------------------------------------------------------------- thresholds
-- Kept in one function so the app can render the same numbers it is judged
-- by, instead of hardcoding a copy that silently drifts.

create or replace function public.trust_thresholds()
returns jsonb
language sql
immutable
as $$
  select jsonb_build_object(
    'trusted_approved', 5,
    'verifier_approved', 20,
    -- Accuracy gates: approvals must outnumber rejections by this factor.
    -- A high-volume account that is wrong a lot never reaches verifier.
    'trusted_ratio', 4,
    'verifier_ratio', 9,
    'verifier_hourly_limit', 30
  );
$$;

-- Explicit ordering. Never compare tier names as text — 'new' < 'trusted' <
-- 'verifier' happens to sort correctly today and would silently invert the
-- moment a tier is renamed.
create or replace function public.trust_rank(p_tier text)
returns integer
language sql
immutable
as $$
  select case p_tier
    when 'verifier' then 2
    when 'trusted' then 1
    else 0
  end;
$$;

create or replace function public.trust_tier_for(
  p_approved integer,
  p_rejected integer
)
returns text
language sql
immutable
as $$
  select case
    when p_approved >= 20 and p_approved >= 9 * p_rejected then 'verifier'
    when p_approved >= 5  and p_approved >= 4 * p_rejected then 'trusted'
    else 'new'
  end;
$$;

-- ------------------------------------------------------------- bookkeeping
-- Internal: called by the decision functions, never by a client.

create or replace function public.bump_trust(
  p_user uuid,
  p_approved boolean
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  old_tier text;
  new_tier text;
  a integer;
  r integer;
begin
  if p_user is null then
    return;
  end if;

  insert into public.user_trust (user_id) values (p_user)
    on conflict (user_id) do nothing;

  update public.user_trust
    set approved_count = approved_count + case when p_approved then 1 else 0 end,
        rejected_count = rejected_count + case when p_approved then 0 else 1 end,
        updated_at = now()
    where user_id = p_user
    returning tier, approved_count, rejected_count into old_tier, a, r;

  new_tier := public.trust_tier_for(a, r);
  if new_tier is distinct from old_tier then
    update public.user_trust
      set tier = new_tier,
          promoted_at = case
            when new_tier <> 'new' then now() else null end
      where user_id = p_user;

    -- Promotions AND demotions are audited: a change in who can publish is
    -- exactly the kind of event that must be reconstructible after the fact.
    insert into public.audit_log
      (actor_id, action, entity, entity_id, before, after)
    values (
      null,
      case when public.trust_rank(new_tier) > public.trust_rank(old_tier)
           then 'promote_user' else 'demote_user' end,
      'user', p_user::text,
      jsonb_build_object('tier', old_tier),
      jsonb_build_object('tier', new_tier, 'approved', a, 'rejected', r)
    );
  end if;
end;
$$;

revoke execute on function public.bump_trust(uuid, boolean) from public, anon, authenticated;

-- ------------------------------------------------------------ verifier gate

create or replace function public.is_verifier()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(
    (select tier = 'verifier' from public.user_trust where user_id = auth.uid()),
    false
  );
$$;

grant execute on function public.is_verifier() to authenticated;

-- Your own standing, including the thresholds you are measured against.
-- An RPC rather than a plain select because most users have no row yet and a
-- missing row must read as "new", not as an error or an empty screen.
create or replace function public.my_trust()
returns jsonb
language sql
stable
security definer
set search_path = public
as $$
  select jsonb_build_object(
    'tier', coalesce(t.tier, 'new'),
    'approved', coalesce(t.approved_count, 0),
    'rejected', coalesce(t.rejected_count, 0),
    'thresholds', public.trust_thresholds()
  )
  from (select 1) one
  left join public.user_trust t on t.user_id = auth.uid();
$$;

revoke execute on function public.my_trust() from public, anon;
grant execute on function public.my_trust() to authenticated;

-- --------------------------------------------- decision functions, extended

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
  v_admin boolean;
  v_recent integer;
begin
  v_admin := public.is_admin();
  if not (v_admin or public.is_verifier()) then
    raise exception 'admin or verifier role required';
  end if;

  select * into sub from public.submissions
    where id = p_submission_id and state = 'pending'
    for update;
  if not found then
    raise exception 'pending submission not found';
  end if;

  -- Verifier restrictions. Checked server-side because a client-side check
  -- is not a check (SECURITY.md).
  if not v_admin then
    if sub.submitter_id = auth.uid() then
      raise exception 'verifiers cannot decide their own submissions';
    end if;

    select count(*) into v_recent from public.audit_log
      where actor_id = auth.uid()
        and action = 'approve_submission'
        and ts > now() - interval '1 hour';
    if v_recent >= (public.trust_thresholds() ->> 'verifier_hourly_limit')::int
    then
      raise exception 'verifier hourly approval limit reached';
    end if;

    -- A verifier approval never carries the admin-verified flag.
    p_mark_verified := false;
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

  -- Creating a pin on the canonical public map stays an admin act: a wrong
  -- status on a known facility gets corrected by the next report, a
  -- fabricated facility does not.
  if target_facility is null and not v_admin then
    raise exception 'verifiers cannot create new facilities';
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
    jsonb_build_object(
      'state', 'approved',
      'facility_id', target_facility,
      'by', case when v_admin then 'admin' else 'verifier' end
    )
  );

  -- Credit the SUBMITTER, not the decider.
  perform public.bump_trust(sub.submitter_id, true);
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
declare
  v_submitter uuid;
begin
  -- Admin-only, unchanged: see the header note on why verifiers may approve
  -- but never reject.
  if not public.is_admin() then
    raise exception 'admin role required';
  end if;
  if p_reason is null or char_length(trim(p_reason)) = 0 then
    raise exception 'reason required';
  end if;

  update public.submissions
    set state = 'rejected', reason = p_reason
    where id = p_submission_id and state = 'pending'
    returning submitter_id into v_submitter;
  if not found then
    raise exception 'pending submission not found';
  end if;

  insert into public.audit_log (actor_id, action, entity, entity_id, before, after)
  values (
    auth.uid(), 'reject_submission', 'submission', p_submission_id::text,
    jsonb_build_object('state', 'pending'),
    jsonb_build_object('state', 'rejected', 'reason', p_reason)
  );

  perform public.bump_trust(v_submitter, false);
end;
$$;

revoke execute on function public.approve_submission from public, anon;
revoke execute on function public.reject_submission from public, anon;
grant execute on function public.approve_submission to authenticated;
grant execute on function public.reject_submission to authenticated;
