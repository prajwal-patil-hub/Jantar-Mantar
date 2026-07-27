-- Corroboration auto-verify negative tests (Phase 4, ADR-26).
--
-- This is the only path that publishes with no human decision at all, so the
-- tests that matter are the ones proving how hard it is to abuse: untrusted
-- accounts do not count, one account cannot corroborate itself, it cannot
-- create a facility, it cannot mark anything admin-verified, and it cannot be
-- farmed for promotion.

begin;
select plan(10);

insert into auth.users (id, aud, role) values
  ('00000000-0000-0000-0000-0000000000d1', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000000d2', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000000d3', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000000d4', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000000d5', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000000d6', 'authenticated', 'authenticated');

insert into public.facilities (id, name, type, status, lat, lng)
values ('44444444-4444-4444-4444-444444444444', 'Water point', 'water', 'good',
        28.6, 77.2);

-- D1..D3 are trusted; D4..D6 are fresh (sock-puppet-shaped) accounts.
insert into public.user_trust (user_id, approved_count, tier) values
  ('00000000-0000-0000-0000-0000000000d1', 6, 'trusted'),
  ('00000000-0000-0000-0000-0000000000d2', 6, 'trusted'),
  ('00000000-0000-0000-0000-0000000000d3', 6, 'trusted'),
  ('00000000-0000-0000-0000-0000000000d4', 0, 'new'),
  ('00000000-0000-0000-0000-0000000000d5', 0, 'new'),
  ('00000000-0000-0000-0000-0000000000d6', 0, 'new');

set local role authenticated;

-- Helper: file a report as a given user.
create or replace function pg_temp.report(
  p_user text, p_client text, p_facility text, p_status text
) returns void language plpgsql as $fn$
begin
  execute format('set local request.jwt.claims to %L',
    json_build_object('sub', p_user, 'role', 'authenticated',
                      'app_metadata', '{}'::json)::text);
  insert into public.submissions (client_id, facility_ref, payload, submitter_id)
  values (p_client, p_facility,
          jsonb_build_object('category', 'water', 'status', p_status),
          p_user::uuid);
end;
$fn$;

-- 1. One trusted report changes nothing.
select pg_temp.report('00000000-0000-0000-0000-0000000000d1',
  'cor-1', '44444444-4444-4444-4444-444444444444', 'out');
reset role;
select is(
  (select status from public.facilities
     where id = '44444444-4444-4444-4444-444444444444'),
  'good',
  'a single trusted report does not publish'
);

-- 2. NEGATIVE: the SAME account reporting three times corroborates nothing.
set local role authenticated;
select pg_temp.report('00000000-0000-0000-0000-0000000000d1',
  'cor-1b', '44444444-4444-4444-4444-444444444444', 'out');
select pg_temp.report('00000000-0000-0000-0000-0000000000d1',
  'cor-1c', '44444444-4444-4444-4444-444444444444', 'out');
reset role;
select is(
  (select status from public.facilities
     where id = '44444444-4444-4444-4444-444444444444'),
  'good',
  'one account cannot corroborate itself by repeating'
);

-- 3. NEGATIVE: a FULL quorum of fresh accounts — the exact sock-puppet
--    attack, three distinct users agreeing — still publishes nothing,
--    because none of them has paid the five-admin-approvals price of
--    'trusted'.
set local role authenticated;
select pg_temp.report('00000000-0000-0000-0000-0000000000d4',
  'cor-4', '44444444-4444-4444-4444-444444444444', 'closed');
select pg_temp.report('00000000-0000-0000-0000-0000000000d5',
  'cor-5', '44444444-4444-4444-4444-444444444444', 'closed');
select pg_temp.report('00000000-0000-0000-0000-0000000000d6',
  'cor-6', '44444444-4444-4444-4444-444444444444', 'closed');
reset role;
select is(
  (select status from public.facilities
     where id = '44444444-4444-4444-4444-444444444444'),
  'good',
  'three fresh sock-puppet accounts agreeing publish nothing'
);

-- 4. NEGATIVE: agreement on a DIFFERENT status is not agreement.
set local role authenticated;
select pg_temp.report('00000000-0000-0000-0000-0000000000d2',
  'cor-2-low', '44444444-4444-4444-4444-444444444444', 'low');
reset role;
select is(
  (select status from public.facilities
     where id = '44444444-4444-4444-4444-444444444444'),
  'good',
  'reports that disagree on status do not corroborate'
);

-- 5. POSITIVE: three distinct trusted accounts agreeing publishes.
set local role authenticated;
select pg_temp.report('00000000-0000-0000-0000-0000000000d2',
  'cor-2', '44444444-4444-4444-4444-444444444444', 'out');
select pg_temp.report('00000000-0000-0000-0000-0000000000d3',
  'cor-3', '44444444-4444-4444-4444-444444444444', 'out');
reset role;
select is(
  (select status from public.facilities
     where id = '44444444-4444-4444-4444-444444444444'),
  'out',
  'three distinct trusted reports publish the agreed status'
);

-- 6. …but never as admin-verified.
select ok(
  (select verified_at is null from public.facilities
     where id = '44444444-4444-4444-4444-444444444444'),
  'corroboration does not set verified_at'
);

-- 7. The agreeing submissions are resolved, not left in the queue.
select is(
  (select count(*)::int from public.submissions
     where client_id in ('cor-1', 'cor-2', 'cor-3') and state = 'approved'),
  3,
  'the corroborating submissions are marked approved'
);

-- 8. The disagreeing one stays pending for a human.
select is(
  (select state from public.submissions where client_id = 'cor-2-low'),
  'pending',
  'a disagreeing report is left in the queue'
);

-- 9. It is audited with no actor and the submitters named.
select ok(
  exists(
    select 1 from public.audit_log
      where action = 'corroborate_submission'
        and actor_id is null
        and jsonb_array_length(after -> 'submitters') = 3
  ),
  'corroboration is audited with every submitter named'
);

-- 10. NEGATIVE: corroboration must not be farmable for promotion.
select is(
  (select approved_count from public.user_trust
     where user_id = '00000000-0000-0000-0000-0000000000d1'),
  6,
  'a corroborated approval does not credit trust'
);

select * from finish();
rollback;
