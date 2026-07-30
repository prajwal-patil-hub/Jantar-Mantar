-- RLS negative tests for the GROUP tables (SECURITY.md gate + the research
-- rule: "don't put group-scoping logic only in the UI — enforce with RLS +
-- negative tests"). These assert what an attacker CANNOT do.
--
-- Run against a local stack: supabase start && supabase test db

begin;
select plan(18);

-- Three users. A owns a group; B is an outsider; C is an ordinary member,
-- used for the key-rotation authority tests at the end.
insert into auth.users (id, aud, role) values
  ('00000000-0000-0000-0000-0000000000a1', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000000b1', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000000c1', 'authenticated', 'authenticated');

-- Seed as A (owner/admin of a hidden group) -------------------------------
set local role authenticated;
set local request.jwt.claims to
  '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated","app_metadata":{}}';

insert into public.device_keys (user_id, public_key, signing_public_key)
values ('00000000-0000-0000-0000-0000000000a1', 'A-PUBLIC-KEY',
        'A-SIGNING-KEY');

insert into public.groups (id, name, visibility, created_by)
values ('11111111-1111-1111-1111-111111111111', 'Medical Volunteers',
        'hidden', '00000000-0000-0000-0000-0000000000a1');

insert into public.group_members (group_id, user_id, role, state)
values ('11111111-1111-1111-1111-111111111111',
        '00000000-0000-0000-0000-0000000000a1', 'admin', 'active');

insert into public.group_key_envelopes (group_id, member_user_id, sealed)
values ('11111111-1111-1111-1111-111111111111',
        '00000000-0000-0000-0000-0000000000a1', 'SEALED-FOR-A');

insert into public.group_messages (group_id, ciphertext)
values ('11111111-1111-1111-1111-111111111111', 'CIPHERTEXT-1');

insert into public.group_pins (group_id, type, label, lat, lng)
values ('11111111-1111-1111-1111-111111111111', 'meeting', 'Secret RV',
        28.62, 77.21);

insert into public.group_invites (group_id, code, expires_at)
values ('11111111-1111-1111-1111-111111111111', 'CODE1234',
        now() + interval '24 hours');

-- 1. Owner/member can see their own group.
select ok(
  (select count(*) from public.groups
     where id = '11111111-1111-1111-1111-111111111111') = 1,
  'active member reads their own group'
);

-- 2. Member can read the group''s messages.
select ok(
  (select count(*) from public.group_messages) = 1,
  'active member reads group messages'
);

-- Switch to B: an outsider, not a member of anything ----------------------
set local request.jwt.claims to
  '{"sub":"00000000-0000-0000-0000-0000000000b1","role":"authenticated","app_metadata":{}}';

-- 3. NEGATIVE: outsider cannot see a hidden group.
select ok(
  (select count(*) from public.groups) = 0,
  'outsider cannot see a hidden group'
);

-- 4. NEGATIVE: outsider cannot read group messages (E2E ciphertext is still
--    not theirs to fetch).
select ok(
  (select count(*) from public.group_messages) = 0,
  'outsider cannot read group messages'
);

-- 5. NEGATIVE: outsider cannot read group-private pins.
select ok(
  (select count(*) from public.group_pins) = 0,
  'outsider cannot read group-private pins (meeting points stay private)'
);

-- 6. NEGATIVE: outsider cannot read the group roster.
select ok(
  (select count(*) from public.group_members) = 0,
  'outsider cannot enumerate group membership'
);

-- 7. NEGATIVE: outsider cannot read invite codes.
select ok(
  (select count(*) from public.group_invites) = 0,
  'outsider cannot harvest invite codes'
);

-- 8. NEGATIVE: outsider cannot read a key envelope sealed to someone else.
select ok(
  (select count(*) from public.group_key_envelopes) = 0,
  'outsider cannot read another member''s sealed group key'
);

-- 9. NEGATIVE: outsider cannot post into a group they are not in.
select throws_ok(
  $$insert into public.group_messages (group_id, ciphertext)
    values ('11111111-1111-1111-1111-111111111111', 'INJECTED')$$,
  '42501', null,
  'outsider cannot send messages into a group'
);

-- 10. NEGATIVE: outsider cannot plant a pin in someone else''s group.
select throws_ok(
  $$insert into public.group_pins (group_id, type, label, lat, lng)
    values ('11111111-1111-1111-1111-111111111111', 'meeting', 'fake',
            28.6, 77.2)$$,
  '42501', null,
  'outsider cannot add pins to a group'
);

-- 11. NEGATIVE: outsider cannot self-join as an ACTIVE member (they may only
--     insert their own row; the default state is pending and approval is an
--     admin-only update).
insert into public.group_members (group_id, user_id, role, state)
values ('11111111-1111-1111-1111-111111111111',
        '00000000-0000-0000-0000-0000000000b1', 'member', 'pending');
update public.group_members set state = 'active'
  where user_id = '00000000-0000-0000-0000-0000000000b1';
select ok(
  (select state from public.group_members
     where user_id = '00000000-0000-0000-0000-0000000000b1') = 'pending',
  'a pending member cannot self-approve to active'
);

-- 12. NEGATIVE: a pending member still cannot read the group''s messages.
select ok(
  (select count(*) from public.group_messages) = 0,
  'pending member cannot read messages before approval'
);

-- ---------------------------------------------------------- key rotation
-- Rotation (ADR-19) is only meaningful if the server enforces who may do it
-- and that a removed member really loses read access.

-- C joins properly: self-inserts a pending row, A approves it.
set local request.jwt.claims to
  '{"sub":"00000000-0000-0000-0000-0000000000c1","role":"authenticated","app_metadata":{}}';
insert into public.group_members (group_id, user_id, role, state)
values ('11111111-1111-1111-1111-111111111111',
        '00000000-0000-0000-0000-0000000000c1', 'member', 'pending');

set local request.jwt.claims to
  '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated","app_metadata":{}}';
update public.group_members set state = 'active'
  where user_id = '00000000-0000-0000-0000-0000000000c1';

set local request.jwt.claims to
  '{"sub":"00000000-0000-0000-0000-0000000000c1","role":"authenticated","app_metadata":{}}';

-- 13. NEGATIVE: an ordinary member cannot mint a new key epoch. Only admins
--     rotate, otherwise anyone could re-key the group out from under it.
select throws_ok(
  $$insert into public.group_key_envelopes (group_id, member_user_id, key_epoch, sealed)
    values ('11111111-1111-1111-1111-111111111111',
            '00000000-0000-0000-0000-0000000000c1', 2, 'SEALED-BY-A-MEMBER')$$,
  '42501', null,
  'a non-admin member cannot issue key envelopes (cannot rotate)'
);

-- 14. NEGATIVE: an ordinary member cannot remove anyone — removal is the
--     admin-only action that triggers rotation. No DELETE policy matches, so
--     the statement simply affects nothing.
delete from public.group_members
  where user_id = '00000000-0000-0000-0000-0000000000a1';
select ok(
  (select count(*) from public.group_members
     where user_id = '00000000-0000-0000-0000-0000000000a1') = 1,
  'a non-admin member cannot remove another member'
);

-- 15. NEGATIVE: once an admin removes them, a former member loses read access
--     to the group''s messages — the server stops serving even the ciphertext.
set local request.jwt.claims to
  '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated","app_metadata":{}}';
delete from public.group_members
  where user_id = '00000000-0000-0000-0000-0000000000c1';

set local request.jwt.claims to
  '{"sub":"00000000-0000-0000-0000-0000000000c1","role":"authenticated","app_metadata":{}}';
select ok(
  (select count(*) from public.group_messages) = 0,
  'a removed member can no longer read group messages'
);

-- 16. NEGATIVE (ADR-29): nobody can publish a signing key on someone else's
--     behalf. This is THE control that makes signatures mean anything — a
--     forged key row would let the attacker sign as that member and have it
--     verify.
select throws_ok(
  $$insert into public.device_keys (user_id, public_key, signing_public_key)
    values ('00000000-0000-0000-0000-0000000000a1', 'fake', 'fake-signing')$$,
  '42501', null,
  'cannot publish a device/signing key for another user'
);

-- 17. NEGATIVE: nor overwrite an existing member's signing key. With no
--     matching update policy row this is a silent no-op, so assert the value.
update public.device_keys set signing_public_key = 'swapped'
  where user_id = '00000000-0000-0000-0000-0000000000a1';
reset role;
select is(
  (select signing_public_key from public.device_keys
     where user_id = '00000000-0000-0000-0000-0000000000a1'),
  'A-SIGNING-KEY',
  'cannot swap another member''s signing key'
);

-- 18. POSITIVE: every member CAN read the roster's signing keys — verification
--     is impossible otherwise.
set local role authenticated;
set local request.jwt.claims to
  '{"sub":"00000000-0000-0000-0000-0000000000b1","role":"authenticated","app_metadata":{}}';
select ok(
  (select count(*) from public.device_keys
     where user_id = '00000000-0000-0000-0000-0000000000a1') = 1,
  'a member can read another member''s signing key to verify with'
);

select * from finish();
rollback;
