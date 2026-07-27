-- Trust / promotion negative tests (Phase 4, ADR-25).
--
-- The promotion system creates a new privileged role, so the tests that
-- matter are the ones proving how narrow it is: a verifier cannot promote
-- themselves, cannot invent a facility, cannot decide their own submission,
-- cannot reject anything, and cannot see anyone else's standing.

begin;
select plan(14);

insert into auth.users (id, aud, role) values
  ('00000000-0000-0000-0000-0000000000c1', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000000c2', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000000c3', 'authenticated', 'authenticated');

insert into public.facilities (id, name, type, status, lat, lng)
values ('22222222-2222-2222-2222-222222222222', 'Water point', 'water', 'good',
        28.6, 77.2);

-- C1 is a verifier; C2 and C3 are ordinary users.
insert into public.user_trust (user_id, approved_count, tier)
values ('00000000-0000-0000-0000-0000000000c1', 25, 'verifier'),
       ('00000000-0000-0000-0000-0000000000c2', 1, 'new');

-- C2's submissions: one updating a known facility, one creating a new pin.
insert into public.submissions (id, client_id, facility_ref, payload, submitter_id)
values ('33333333-3333-3333-3333-333333333331',
        'trust-update', '22222222-2222-2222-2222-222222222222',
        '{"category":"water","status":"low"}',
        '00000000-0000-0000-0000-0000000000c2'),
       ('33333333-3333-3333-3333-333333333332',
        'trust-new', null,
        '{"category":"food","status":"good"}',
        '00000000-0000-0000-0000-0000000000c2');

-- C1's own submission, to prove a verifier cannot self-deal.
insert into public.submissions (id, client_id, facility_ref, payload, submitter_id)
values ('33333333-3333-3333-3333-333333333333',
        'trust-own', '22222222-2222-2222-2222-222222222222',
        '{"category":"water","status":"out"}',
        '00000000-0000-0000-0000-0000000000c1');

set local role authenticated;
set local request.jwt.claims to
  '{"sub":"00000000-0000-0000-0000-0000000000c1","role":"authenticated","app_metadata":{}}';

-- 1. The verifier gate reads from the table, not from a client claim.
select ok(public.is_verifier(), 'trust tier verifier grants is_verifier()');

-- 2. NEGATIVE: nobody can write their own trust row — there is no insert
--    policy at all, so self-promotion is impossible by construction.
select throws_ok(
  $$insert into public.user_trust (user_id, tier)
    values ('00000000-0000-0000-0000-0000000000c3', 'verifier')$$,
  '42501', null,
  'cannot insert a trust row'
);

-- 3. NEGATIVE: nor update an existing one. With no update policy the
--    statement is a silent no-op rather than an error, so assert the value.
update public.user_trust set tier = 'verifier'
  where user_id = '00000000-0000-0000-0000-0000000000c2';
select is(
  (select tier from public.user_trust
     where user_id = '00000000-0000-0000-0000-0000000000c2'),
  null,
  'cannot promote another user (row is not even visible, let alone writable)'
);

-- 4. NEGATIVE: a verifier sees only their own standing.
select ok(
  (select count(*) from public.user_trust) = 1,
  'verifier cannot read other users'' trust rows'
);

-- 5. NEGATIVE: a verifier cannot create a facility from a submission.
select throws_ok(
  $$select public.approve_submission(
      '33333333-3333-3333-3333-333333333332'::uuid)$$,
  'P0001', 'verifiers cannot create new facilities',
  'verifier cannot publish a brand-new pin'
);

-- 6. NEGATIVE: a verifier cannot decide their own submission.
select throws_ok(
  $$select public.approve_submission(
      '33333333-3333-3333-3333-333333333333'::uuid)$$,
  'P0001', 'verifiers cannot decide their own submissions',
  'verifier cannot self-approve'
);

-- 7. NEGATIVE: rejection stays admin-only.
select throws_ok(
  $$select public.reject_submission(
      '33333333-3333-3333-3333-333333333331'::uuid, 'nope')$$,
  'P0001', 'admin role required',
  'verifier cannot reject'
);

-- 8. POSITIVE: a verifier CAN approve an update to a known facility.
select lives_ok(
  $$select public.approve_submission(
      '33333333-3333-3333-3333-333333333331'::uuid)$$,
  'verifier approves an update to an existing facility'
);

-- 9. …and it published.
select is(
  (select status from public.facilities
     where id = '22222222-2222-2222-2222-222222222222'),
  'low',
  'verifier approval updates the facility status'
);

-- 10. …but WITHOUT the admin-verified flag (ADR-2's second axis).
select ok(
  (select verified_at is null from public.facilities
     where id = '22222222-2222-2222-2222-222222222222'),
  'verifier approval does not set verified_at'
);

-- 11. The submitter, not the decider, gains the trust point. Asserted as the
--     owner, because test 4 just proved the verifier cannot see this row.
reset role;
select is(
  (select approved_count from public.user_trust
     where user_id = '00000000-0000-0000-0000-0000000000c2'),
  2,
  'the submitter is credited for an approval'
);

-- 12. NEGATIVE: an ordinary user cannot approve anything.
set local role authenticated;
set local request.jwt.claims to
  '{"sub":"00000000-0000-0000-0000-0000000000c2","role":"authenticated","app_metadata":{}}';
select throws_ok(
  $$select public.approve_submission(
      '33333333-3333-3333-3333-333333333333'::uuid)$$,
  'P0001', 'admin or verifier role required',
  'a new user cannot approve'
);

-- 13. my_trust() reports "new" for a user with no row, never an error.
set local request.jwt.claims to
  '{"sub":"00000000-0000-0000-0000-0000000000c3","role":"authenticated","app_metadata":{}}';
select is(
  public.my_trust() ->> 'tier',
  'new',
  'a user with no trust row reads as new'
);

-- 14. Demotion is possible: the tier is recomputed, never latched.
select is(
  public.trust_tier_for(20, 5),
  'trusted',
  'a verifier-volume account with poor accuracy is not a verifier'
);

select * from finish();
rollback;
