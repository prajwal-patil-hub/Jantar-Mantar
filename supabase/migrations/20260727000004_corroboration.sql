-- Phase 4 — corroboration auto-verify (ADR-26).
--
-- The other half of the bottleneck fix. Trust promotion (ADR-25) adds more
-- people who can approve; corroboration handles the case where nobody is
-- available at all: when several independent, already-trusted reporters
-- agree that a known facility is in the same state, that agreement publishes
-- on its own.
--
-- The whole risk here is sock puppets: anonymous sign-in is free, so "three
-- users agree" is worth nothing by itself. Three defences:
--   1. Only submissions from accounts at tier 'trusted' or better count, and
--      that tier costs five admin-approved reports EACH to reach.
--   2. Corroborated approvals do NOT credit trust. Otherwise a ring of three
--      trusted accounts could corroborate each other up to verifier without
--      an admin ever seeing them again.
--   3. It can only change the status of a facility that ALREADY exists, and
--      never sets verified_at — the same envelope a verifier gets.
-- Worst case is therefore a status flip on a known pin, corrected by the next
-- report, and the audit row names every submitter involved.

create or replace function public.corroboration_settings()
returns jsonb
language sql
immutable
as $$
  select jsonb_build_object(
    'min_reports', 3,
    'window_minutes', 20
  );
$$;

create or replace function public.try_corroborate()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_facility uuid;
  v_status text;
  v_window interval;
  v_min integer;
  v_agreeing integer;
  v_submitters uuid[];
begin
  -- Only a pending report against an existing facility, carrying a status.
  if new.state <> 'pending' or new.facility_ref is null then
    return new;
  end if;
  v_status := new.payload ->> 'status';
  if v_status is null then
    return new;
  end if;

  begin
    select id into v_facility from public.facilities
      where id = new.facility_ref::uuid;
  exception when invalid_text_representation then
    return new;
  end;
  if v_facility is null then
    return new;
  end if;

  v_min := (public.corroboration_settings() ->> 'min_reports')::int;
  v_window := make_interval(
    mins => (public.corroboration_settings() ->> 'window_minutes')::int
  );

  -- Distinct trusted submitters agreeing on the same facility AND the same
  -- status inside the window. Distinct on submitter, so one account filing
  -- the same report three times corroborates nothing.
  select array_agg(distinct s.submitter_id) into v_submitters
  from public.submissions s
  join public.user_trust t on t.user_id = s.submitter_id
  where s.facility_ref = new.facility_ref
    and s.state = 'pending'
    and (s.payload ->> 'status') = v_status
    and s.created_at > now() - v_window
    and t.tier in ('trusted', 'verifier');

  v_agreeing := coalesce(array_length(v_submitters, 1), 0);
  if v_agreeing < v_min then
    return new;
  end if;

  -- Publish, but never as admin-verified (ADR-2's second axis).
  update public.facilities
    set status = v_status,
        updated_at = now()
    where id = v_facility;

  update public.submissions s
    set state = 'approved'
    where s.facility_ref = new.facility_ref
      and s.state = 'pending'
      and (s.payload ->> 'status') = v_status
      and s.created_at > now() - v_window
      and s.submitter_id = any(v_submitters);

  -- actor_id is null: no human decided this. The submitters are named so the
  -- decision is still reconstructible — and so a colluding ring is visible.
  insert into public.audit_log
    (actor_id, action, entity, entity_id, before, after)
  values (
    null, 'corroborate_submission', 'facility', v_facility::text,
    jsonb_build_object('status', 'pending'),
    jsonb_build_object(
      'status', v_status,
      'reports', v_agreeing,
      'submitters', to_jsonb(v_submitters)
    )
  );

  -- Deliberately NO bump_trust here: corroboration must not be a path to
  -- promotion, or a ring of trusted accounts could farm each other.
  return new;
end;
$$;

create trigger submissions_corroborate
  after insert on public.submissions
  for each row execute function public.try_corroborate();
