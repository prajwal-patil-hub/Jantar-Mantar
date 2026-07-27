-- RLS negative tests (SECURITY.md gate: "policies tested with automated
-- negative tests"). Run with the Supabase CLI against a local stack:
--   supabase start && supabase test db
-- pgTAP: each test simulates a JWT via request.jwt.claims.

begin;
select plan(10);

-- Two fake users.
insert into auth.users (id, aud, role)
values ('00000000-0000-0000-0000-00000000000a', 'authenticated', 'authenticated'),
       ('00000000-0000-0000-0000-00000000000b', 'authenticated', 'authenticated');

-- Seed one facility + one submission owned by user A.
insert into public.facilities (id, name, type, status, lat, lng)
values ('11111111-1111-1111-1111-111111111111', 'Water point', 'water', 'good', 28.6, 77.2);

set local role authenticated;
set local request.jwt.claims to
  '{"sub":"00000000-0000-0000-0000-00000000000a","role":"authenticated","app_metadata":{}}';

insert into public.submissions (client_id, payload, submitter_id)
values ('sub-a-1', '{"category":"water","status":"good"}',
        '00000000-0000-0000-0000-00000000000a');

-- 1. Anyone authenticated can read facilities.
select ok(
  (select count(*) from public.facilities) = 1,
  'authenticated user reads public facilities'
);

-- 2. Owner sees own submission.
select ok(
  (select count(*) from public.submissions where client_id = 'sub-a-1') = 1,
  'owner reads own submission'
);

-- Switch to user B (non-admin).
set local request.jwt.claims to
  '{"sub":"00000000-0000-0000-0000-00000000000b","role":"authenticated","app_metadata":{}}';

-- 3. NEGATIVE: user B cannot see user A''s submission.
select ok(
  (select count(*) from public.submissions) = 0,
  'non-owner cannot read another user''s submissions'
);

-- 4. NEGATIVE: user B cannot insert a submission owned by A.
select throws_ok(
  $$insert into public.submissions (client_id, payload, submitter_id)
    values ('sub-forged', '{}', '00000000-0000-0000-0000-00000000000a')$$,
  '42501', null,
  'cannot forge submitter_id'
);

-- 5. NEGATIVE: user B cannot insert a pre-approved submission.
select throws_ok(
  $$insert into public.submissions (client_id, payload, state)
    values ('sub-approved', '{}', 'approved')$$,
  '42501', null,
  'cannot self-approve on insert'
);

-- 6. NEGATIVE: non-admin cannot update submission state directly.
set local request.jwt.claims to
  '{"sub":"00000000-0000-0000-0000-00000000000a","role":"authenticated","app_metadata":{}}';
update public.submissions set state = 'approved' where client_id = 'sub-a-1';
select ok(
  (select state from public.submissions where client_id = 'sub-a-1') = 'pending',
  'direct state update is a no-op without an update policy'
);

-- 7. NEGATIVE: non-admin cannot broadcast alerts.
select throws_ok(
  $$insert into public.alerts (severity, body, expires_at)
    values ('critical', 'fake', now() + interval '1 hour')$$,
  '42501', null,
  'non-admin cannot insert alerts'
);

-- 8. NEGATIVE: non-admin cannot call approve_submission. Since ADR-25 a
--    promoted verifier can also approve (narrowly); an untrusted user still
--    cannot, and the message names both roles.
select throws_ok(
  $$select public.approve_submission(
      (select id from public.submissions where client_id = 'sub-a-1'))$$,
  'P0001', 'admin or verifier role required',
  'approve_submission rejects users who are neither admin nor verifier'
);

-- 9. NEGATIVE: non-admin cannot read the audit log.
select ok(
  (select count(*) from public.audit_log) = 0,
  'non-admin sees empty audit log'
);

-- 10. NEGATIVE: non-admin cannot read others'' SOS signals.
select ok(
  (select count(*) from public.sos_signals) = 0,
  'non-admin cannot read SOS signals'
);

select * from finish();
rollback;
