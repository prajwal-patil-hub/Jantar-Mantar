-- RLS negative tests for the group self-join escalation (ADR-36).
--
-- The bug these exist for: `members_self_join` checked only `user_id`, so an
-- attacker could POST a group_members row with role='admin', state='active'
-- and become an admin of any group whose id they knew. Column defaults did
-- not save it — a default only applies to an OMITTED column, and the attacker
-- supplies it.
--
-- The old suite never caught this because it only tested the READ policies:
-- "an outsider cannot read group X". It never tested the write that turns an
-- outsider into an insider. These tests attack the membership write itself.

begin;
select plan(16);

insert into auth.users (id, aud, role) values
  ('00000000-0000-0000-0000-0000000000a2', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000000b2', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-0000000000c2', 'authenticated', 'authenticated');

-- A creates a PUBLIC group. Public because that is the worst case: its id is
-- readable by anyone through `groups_read`, so the attacker does not even
-- need to guess a UUID.
set local role authenticated;
set local request.jwt.claims to
  '{"sub":"00000000-0000-0000-0000-0000000000a2","role":"authenticated","app_metadata":{}}';

insert into public.groups (id, name, visibility, created_by)
values ('22222222-2222-2222-2222-222222222222', 'Legal Support',
        'public', '00000000-0000-0000-0000-0000000000a2');

-- 1. POSITIVE: the trigger seeded the creator. Nothing client-side did this.
select is(
  (select count(*)::int from public.group_members
     where group_id = '22222222-2222-2222-2222-222222222222'
       and user_id = '00000000-0000-0000-0000-0000000000a2'
       and role = 'admin' and state = 'active'),
  1,
  'creating a group seeds the creator as an active admin, server-side'
);

-- 2. POSITIVE: and seeds exactly one row, not a duplicate per retry.
select is(
  (select count(*)::int from public.group_members
     where group_id = '22222222-2222-2222-2222-222222222222'),
  1,
  'exactly one membership row after creation'
);

insert into public.group_pins (group_id, type, label, lat, lng)
values ('22222222-2222-2222-2222-222222222222', 'meeting', 'Rendezvous',
        28.62, 77.21);

insert into public.group_invites (group_id, code, expires_at, max_uses)
values ('22222222-2222-2222-2222-222222222222', 'JOIN9999',
        now() + interval '24 hours', 2);

-- ------------------------------------------------------------- the attack

set local request.jwt.claims to
  '{"sub":"00000000-0000-0000-0000-0000000000b2","role":"authenticated","app_metadata":{}}';

-- 3. THE ESCALATION, dead. This is the exact request the old policy allowed.
select throws_ok(
  $$insert into public.group_members (group_id, user_id, role, state)
    values ('22222222-2222-2222-2222-222222222222',
            '00000000-0000-0000-0000-0000000000b2', 'admin', 'active')$$,
  '42501',
  null,
  'an outsider cannot insert themselves as an active admin'
);

-- 4. Nor as an ordinary active member — "active" is the whole prize.
select throws_ok(
  $$insert into public.group_members (group_id, user_id, role, state)
    values ('22222222-2222-2222-2222-222222222222',
            '00000000-0000-0000-0000-0000000000b2', 'member', 'active')$$,
  '42501',
  null,
  'nor as an active member'
);

-- 5. Nor even a harmless-looking pending row: the policy is gone, not
--    narrowed, so there is no client INSERT path left to reason about.
select throws_ok(
  $$insert into public.group_members (group_id, user_id, role, state)
    values ('22222222-2222-2222-2222-222222222222',
            '00000000-0000-0000-0000-0000000000b2', 'member', 'pending')$$,
  '42501',
  null,
  'and not a pending row either — joining goes through join_by_invite'
);

-- 6. The outsider still cannot see the group's real-world pin coordinates.
select is(
  (select count(*)::int from public.group_pins
     where group_id = '22222222-2222-2222-2222-222222222222'),
  0,
  'an outsider reads no group pins'
);

-- 7. Nor the roster — the roster IS the sensitive data in this threat model.
select is(
  (select count(*)::int from public.group_members
     where group_id = '22222222-2222-2222-2222-222222222222'),
  0,
  'an outsider reads no roster'
);

-- 8. Nor live invite codes, which would be a self-service way back in.
select is(
  (select count(*)::int from public.group_invites
     where group_id = '22222222-2222-2222-2222-222222222222'),
  0,
  'an outsider reads no invite codes'
);

-- --------------------------------------------------- the legitimate path

-- 9. POSITIVE: a valid code admits B — as PENDING, never active.
select lives_ok(
  $$select * from public.join_by_invite('JOIN9999')$$,
  'a valid invite code is accepted'
);

reset role;
select is(
  (select state from public.group_members
     where group_id = '22222222-2222-2222-2222-222222222222'
       and user_id = '00000000-0000-0000-0000-0000000000b2'),
  'pending',
  'join_by_invite can only ever write a pending row'
);

-- 10. And the function cannot be talked into granting admin either.
select is(
  (select role from public.group_members
     where group_id = '22222222-2222-2222-2222-222222222222'
       and user_id = '00000000-0000-0000-0000-0000000000b2'),
  'member',
  'join_by_invite can only ever write the member role'
);

-- 11. Pending is not membership: B still sees nothing.
set local role authenticated;
select is(
  (select count(*)::int from public.group_pins
     where group_id = '22222222-2222-2222-2222-222222222222'),
  0,
  'a pending request grants no read access — approval still gates everything'
);

-- 12. Re-scanning the same QR must not spend another invite use.
select lives_ok(
  $$select * from public.join_by_invite('JOIN9999')$$,
  'rejoining is idempotent, not an error'
);
reset role;
select is(
  (select uses from public.group_invites where code = 'JOIN9999'),
  1,
  're-scanning does not consume a second use'
);

-- 13. A ban is not undone by finding another invite link.
update public.group_members set state = 'banned'
  where group_id = '22222222-2222-2222-2222-222222222222'
    and user_id = '00000000-0000-0000-0000-0000000000b2';

set local role authenticated;
select throws_ok(
  $$select * from public.join_by_invite('JOIN9999')$$,
  null,
  'membership refused',
  'a banned member cannot rejoin with a fresh invite'
);

-- 14. An unknown code is refused rather than silently creating nothing.
select throws_ok(
  $$select * from public.join_by_invite('NOSUCHCODE')$$,
  null,
  'invite is invalid, expired, or used up',
  'an unknown invite code is refused'
);

select * from finish();
rollback;
