-- CommonGround — close the group self-join privilege escalation (ADR-36).
--
-- THE HOLE
-- --------
-- The original policy was:
--
--   create policy members_self_join on public.group_members
--     for insert to authenticated with check (user_id = auth.uid());
--
-- `role` and `state` have safe defaults ('member', 'pending'), but a column
-- default only applies when the column is OMITTED. The WITH CHECK constrained
-- `user_id` and nothing else, so any authenticated caller could simply supply
-- them:
--
--   POST /rest/v1/group_members
--   { "group_id": "<any public group>", "user_id": "<self>",
--     "role": "admin", "state": "active" }
--
-- That passes the check and lands an active admin row. `is_group_member()` and
-- `is_group_admin()` then return true, which unlocks the member roster, the
-- group's real-world pin coordinates, live invite codes, group renaming and
-- member deletion.
--
-- Reachable by anyone: the publishable key ships in the web bundle by design,
-- the app signs in anonymously on its own, and an anonymous Supabase session
-- holds the `authenticated` role — `to authenticated` is not a barrier. Public
-- group ids are enumerable through `groups_read` (visibility = 'public').
--
-- E2E encryption held: message bodies stay unreadable without an envelope
-- sealed to the attacker's X25519 key. Everything around them did not, and for
-- this threat model the roster IS the sensitive data.
--
-- THE FIX
-- -------
-- No client INSERT on group_members at all. Both legitimate paths become
-- SECURITY DEFINER functions, so the privileged write lives in one auditable
-- place instead of in a policy that has to enumerate what may not be set:
--
--   · creating a group  -> AFTER INSERT trigger seeds the creator
--   · joining a group   -> join_by_invite() validates the code, then inserts
--
-- Deny-by-default, as CONTEXT.md requires. Apply AFTER 20260725000002_groups.

-- ------------------------------------------------------- creator seeding

-- The creator must end up as the first active admin, but the client must not
-- be the one asserting that. A trigger cannot be skipped by a crafted request
-- the way a client-side insert can.
create or replace function public.seed_group_creator()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.group_members (group_id, user_id, role, state, joined_via)
  values (new.id, new.created_by, 'admin', 'active', 'creator')
  on conflict (group_id, user_id) do nothing;
  return new;
end;
$$;

drop trigger if exists groups_seed_creator on public.groups;
create trigger groups_seed_creator
  after insert on public.groups
  for each row execute function public.seed_group_creator();

-- ------------------------------------------------------------ invite join

-- Validates the code and creates the PENDING row in one privileged step, so
-- the caller never touches group_members directly and cannot choose its own
-- role or state. Approval stays mandatory: this only ever writes 'pending'.
create or replace function public.join_by_invite(p_code text)
returns table(group_id uuid, group_name text)
language plpgsql security definer set search_path = public as $$
declare
  v_invite   public.group_invites%rowtype;
  v_group    public.groups%rowtype;
  v_existing public.group_members%rowtype;
  v_uid      uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'authentication required';
  end if;

  -- FOR UPDATE so two devices redeeming the last use cannot both win.
  select * into v_invite
  from public.group_invites
  where code = p_code
    and not revoked
    and expires_at > now()
    and uses < max_uses
  for update;

  if not found then
    raise exception 'invite is invalid, expired, or used up';
  end if;

  select * into v_group from public.groups where id = v_invite.group_id;

  select * into v_existing
  from public.group_members
  where public.group_members.group_id = v_invite.group_id
    and user_id = v_uid;

  -- A ban is not undone by finding another invite link.
  if found and v_existing.state = 'banned' then
    raise exception 'membership refused';
  end if;

  -- Idempotent: re-scanning the QR must not spend another use or duplicate
  -- the request. Only a genuinely new request consumes an invite use.
  if not found then
    insert into public.group_members
      (group_id, user_id, role, state, joined_via)
    values (v_invite.group_id, v_uid, 'member', 'pending', 'link');

    update public.group_invites
      set uses = uses + 1
      where id = v_invite.id;
  end if;

  return query select v_group.id, v_group.name;
end;
$$;

revoke execute on function public.join_by_invite from public, anon;
grant execute on function public.join_by_invite to authenticated;

-- --------------------------------------------------------------- the policy

-- Removed, not narrowed. A narrowed version would still be a policy whose
-- correctness depends on listing every column an attacker must not set, and
-- the next column added to this table would silently reopen the hole.
drop policy if exists members_self_join on public.group_members;
