-- Moderator tooling negative tests (Phase 4, ADR-27).
--
-- Automatic promotion needs a manual brake, and the brake has to actually
-- hold: the failure mode worth testing is a revocation that lasts only until
-- the next approved submission recomputes the tier and hands the badge back.

begin;
select plan(12);

insert into auth.users (id, aud, role) values
  ('00000000-0000-0000-0000-0000000000e1', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000000e2', 'authenticated', 'authenticated');

insert into public.facilities (id, name, type, status, lat, lng)
values ('55555555-5555-5555-5555-555555555555', 'Water point', 'water', 'good',
        28.6, 77.2);

-- E1 is a verifier by the automatic path.
insert into public.user_trust (user_id, approved_count, tier)
values ('00000000-0000-0000-0000-0000000000e1', 25, 'verifier');

insert into public.submissions (id, client_id, facility_ref, payload, submitter_id)
values ('66666666-6666-6666-6666-666666666661',
        'mod-1', '55555555-5555-5555-5555-555555555555',
        '{"category":"water","status":"low"}',
        '00000000-0000-0000-0000-0000000000e2');

set local role authenticated;

-- 1. NEGATIVE: a non-admin cannot revoke anyone.
set local request.jwt.claims to
  '{"sub":"00000000-0000-0000-0000-0000000000e1","role":"authenticated","app_metadata":{}}';
select throws_ok(
  $$select public.revoke_verifier(
      '00000000-0000-0000-0000-0000000000e2'::uuid, 'because')$$,
  'P0001', 'admin role required',
  'a verifier cannot revoke another user'
);

-- 2. NEGATIVE: nor restore one.
select throws_ok(
  $$select public.restore_trust('00000000-0000-0000-0000-0000000000e1'::uuid)$$,
  'P0001', 'admin role required',
  'a verifier cannot lift a hold'
);

-- 3. NEGATIVE: an admin must give a reason.
set local request.jwt.claims to
  '{"sub":"00000000-0000-0000-0000-0000000000e2","role":"authenticated","app_metadata":{"role":"admin"}}';
select throws_ok(
  $$select public.revoke_verifier(
      '00000000-0000-0000-0000-0000000000e1'::uuid, '   ')$$,
  'P0001', 'reason required',
  'revoking requires a stated reason'
);

-- 4. NEGATIVE: and cannot revoke themselves.
select throws_ok(
  $$select public.revoke_verifier(
      '00000000-0000-0000-0000-0000000000e2'::uuid, 'oops')$$,
  'P0001', 'cannot revoke your own standing',
  'an admin cannot revoke their own standing'
);

-- 5. POSITIVE: the revocation lands.
select lives_ok(
  $$select public.revoke_verifier(
      '00000000-0000-0000-0000-0000000000e1'::uuid, 'infiltration report')$$,
  'an admin revokes a verifier'
);

-- 6. The verifier gate closes immediately.
set local request.jwt.claims to
  '{"sub":"00000000-0000-0000-0000-0000000000e1","role":"authenticated","app_metadata":{}}';
select ok(not public.is_verifier(), 'a revoked account is not a verifier');

-- 7. NEGATIVE: and can no longer approve.
select throws_ok(
  $$select public.approve_submission(
      '66666666-6666-6666-6666-666666666661'::uuid)$$,
  'P0001', 'admin or verifier role required',
  'a revoked verifier cannot approve'
);

-- 8. THE ONE THAT MATTERS: further approved submissions must NOT hand the
--    badge back. Credit 30 approvals to the held account and check the tier.
reset role;
select public.bump_trust('00000000-0000-0000-0000-0000000000e1'::uuid, true)
  from generate_series(1, 30);
select is(
  (select tier from public.user_trust
     where user_id = '00000000-0000-0000-0000-0000000000e1'),
  'new',
  'a held account is not re-promoted by the automatic path'
);

-- 9. …while the counters keep an honest record.
select ok(
  (select approved_count from public.user_trust
     where user_id = '00000000-0000-0000-0000-0000000000e1') = 55,
  'a hold stops promotion without falsifying the counts'
);

-- 10. The revocation is audited with the acting admin and the reason.
select ok(
  exists(
    select 1 from public.audit_log
      where action = 'revoke_verifier'
        and actor_id = '00000000-0000-0000-0000-0000000000e2'
        and after ->> 'reason' = 'infiltration report'
  ),
  'revocation is audited with the admin and the reason'
);

-- 11. Restoring recomputes from the record rather than handing back the old
--     badge — the counters are the source of truth again.
set local role authenticated;
set local request.jwt.claims to
  '{"sub":"00000000-0000-0000-0000-0000000000e2","role":"authenticated","app_metadata":{"role":"admin"}}';
select public.restore_trust('00000000-0000-0000-0000-0000000000e1'::uuid);
select is(
  (select tier from public.user_trust
     where user_id = '00000000-0000-0000-0000-0000000000e1'),
  'verifier',
  'lifting a hold recomputes the tier from the counters'
);

-- 12. NEGATIVE: reporter_history runs as the caller, so a non-admin cannot
--     use it to read someone else's submissions.
set local request.jwt.claims to
  '{"sub":"00000000-0000-0000-0000-0000000000e1","role":"authenticated","app_metadata":{}}';
select is(
  jsonb_array_length(
    public.reporter_history('00000000-0000-0000-0000-0000000000e2'::uuid)
      -> 'recent'
  ),
  0,
  'a non-admin cannot read another reporter''s submission history'
);

select * from finish();
rollback;
