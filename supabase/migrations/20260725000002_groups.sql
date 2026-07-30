-- CommonGround groups + end-to-end encrypted chat (Phase 3 / ADR-16).
-- Security: RLS deny-by-default. Only active members can read a group's rows.
-- The server stores ONLY public keys, sealed key envelopes, and message
-- ciphertext — never a group key or plaintext.
--
-- Order matters: tables first, then the `language sql` helper functions
-- (validated at creation time, so they must see the tables), then RLS
-- policies (which call the helpers).

-- ------------------------------------------------------------------------ tables

-- Each user's X25519 public key (for sealing group keys to them). Public keys
-- only — private keys never leave the device.
create table if not exists public.device_keys (
  user_id uuid primary key default auth.uid() references auth.users(id),
  public_key text not null check (char_length(public_key) <= 128),
  updated_at timestamptz not null default now()
);

create table if not exists public.groups (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 1 and 80),
  description text check (char_length(description) <= 500),
  visibility text not null default 'hidden' check (visibility in ('public','hidden')),
  created_by uuid not null default auth.uid() references auth.users(id),
  created_at timestamptz not null default now()
);

create table if not exists public.group_members (
  group_id uuid not null references public.groups(id) on delete cascade,
  user_id uuid not null default auth.uid() references auth.users(id),
  role text not null default 'member' check (role in ('admin','member')),
  state text not null default 'pending' check (state in ('pending','active','banned')),
  display_name text check (char_length(display_name) <= 60),
  joined_via text check (char_length(joined_via) <= 40),
  created_at timestamptz not null default now(),
  primary key (group_id, user_id)
);
create index if not exists group_members_user_idx on public.group_members(user_id, state);

-- The group key, sealed (ECIES) to one member's device key. Epoch supports
-- future key rotation on membership change.
create table if not exists public.group_key_envelopes (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups(id) on delete cascade,
  member_user_id uuid not null references auth.users(id),
  key_epoch integer not null default 1,
  sealed text not null,
  created_at timestamptz not null default now(),
  unique (group_id, member_user_id, key_epoch)
);
create index if not exists group_envelopes_member_idx
  on public.group_key_envelopes(member_user_id, group_id);

create table if not exists public.group_invites (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups(id) on delete cascade,
  code text not null unique check (char_length(code) between 6 and 64),
  expires_at timestamptz not null,
  max_uses integer not null default 10 check (max_uses between 1 and 1000),
  uses integer not null default 0,
  revoked boolean not null default false,
  created_by uuid not null default auth.uid() references auth.users(id),
  created_at timestamptz not null default now()
);

-- Group-private pins ("amenities": meeting points, supplies). Never promotable
-- to the public map; enforced here at the DB layer, not just the UI.
create table if not exists public.group_pins (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups(id) on delete cascade,
  type text not null check (type in ('meeting','supply','medical','water','food','custom')),
  label text not null check (char_length(label) <= 80),
  lat double precision not null check (lat between -90 and 90),
  lng double precision not null check (lng between -180 and 180),
  note text check (char_length(note) <= 300),
  created_by uuid not null default auth.uid() references auth.users(id),
  created_at timestamptz not null default now(),
  expires_at timestamptz
);

-- E2E chat: ciphertext only (AES-GCM under the group key).
create table if not exists public.group_messages (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups(id) on delete cascade,
  sender_id uuid not null default auth.uid() references auth.users(id),
  ciphertext text not null,
  key_epoch integer not null default 1,
  created_at timestamptz not null default now()
);
create index if not exists group_messages_group_idx on public.group_messages(group_id, created_at);

-- ------------------------------------------------------------- membership helpers
-- Created after the tables they read (language sql = validated at creation).

create or replace function public.is_group_member(g uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists(
    select 1 from public.group_members
    where group_id = g and user_id = auth.uid() and state = 'active'
  );
$$;

create or replace function public.is_group_admin(g uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists(
    select 1 from public.group_members
    where group_id = g and user_id = auth.uid()
      and state = 'active' and role = 'admin'
  );
$$;

-- --------------------------------------------------------------------------- RLS

alter table public.device_keys enable row level security;
alter table public.groups enable row level security;
alter table public.group_members enable row level security;
alter table public.group_key_envelopes enable row level security;
alter table public.group_invites enable row level security;
alter table public.group_pins enable row level security;
alter table public.group_messages enable row level security;

-- device_keys: anyone signed in can read a public key (needed to seal to it);
-- a user writes only their own.
drop policy if exists device_keys_read on public.device_keys;
create policy device_keys_read on public.device_keys
  for select to authenticated using (true);
drop policy if exists device_keys_upsert on public.device_keys;
create policy device_keys_upsert on public.device_keys
  for insert to authenticated with check (user_id = auth.uid());
drop policy if exists device_keys_update on public.device_keys;
create policy device_keys_update on public.device_keys
  for update to authenticated using (user_id = auth.uid());

-- groups: members read; public groups are discoverable; creator inserts.
drop policy if exists groups_read on public.groups;
create policy groups_read on public.groups
  for select to authenticated
  using (visibility = 'public' or public.is_group_member(id));
drop policy if exists groups_insert on public.groups;
create policy groups_insert on public.groups
  for insert to authenticated with check (created_by = auth.uid());
drop policy if exists groups_admin_update on public.groups;
create policy groups_admin_update on public.groups
  for update to authenticated using (public.is_group_admin(id));

-- group_members: a member sees the roster of groups they belong to; a user can
-- insert their OWN pending row (join request) or the creator seeds admin.
drop policy if exists members_read on public.group_members;
create policy members_read on public.group_members
  for select to authenticated
  using (user_id = auth.uid() or public.is_group_member(group_id));
drop policy if exists members_self_join on public.group_members;
create policy members_self_join on public.group_members
  for insert to authenticated with check (user_id = auth.uid());
drop policy if exists members_admin_manage on public.group_members;
create policy members_admin_manage on public.group_members
  for update to authenticated using (public.is_group_admin(group_id));
drop policy if exists members_admin_delete on public.group_members;
create policy members_admin_delete on public.group_members
  for delete to authenticated using (public.is_group_admin(group_id));

-- envelopes: a member reads envelopes sealed to them; admins create them.
drop policy if exists envelopes_read_own on public.group_key_envelopes;
create policy envelopes_read_own on public.group_key_envelopes
  for select to authenticated using (member_user_id = auth.uid());
drop policy if exists envelopes_admin_insert on public.group_key_envelopes;
create policy envelopes_admin_insert on public.group_key_envelopes
  for insert to authenticated with check (public.is_group_admin(group_id));

-- invites: members read; admins manage.
drop policy if exists invites_member_read on public.group_invites;
create policy invites_member_read on public.group_invites
  for select to authenticated using (public.is_group_member(group_id));
drop policy if exists invites_admin_insert on public.group_invites;
create policy invites_admin_insert on public.group_invites
  for insert to authenticated with check (public.is_group_admin(group_id));
drop policy if exists invites_admin_update on public.group_invites;
create policy invites_admin_update on public.group_invites
  for update to authenticated using (public.is_group_admin(group_id));

-- pins: members read/write within their group.
drop policy if exists pins_member_read on public.group_pins;
create policy pins_member_read on public.group_pins
  for select to authenticated using (public.is_group_member(group_id));
drop policy if exists pins_member_insert on public.group_pins;
create policy pins_member_insert on public.group_pins
  for insert to authenticated with check (public.is_group_member(group_id));
drop policy if exists pins_admin_delete on public.group_pins;
create policy pins_admin_delete on public.group_pins
  for delete to authenticated using (public.is_group_admin(group_id));

-- messages: members read all group messages and send as themselves.
drop policy if exists messages_member_read on public.group_messages;
create policy messages_member_read on public.group_messages
  for select to authenticated using (public.is_group_member(group_id));
drop policy if exists messages_member_send on public.group_messages;
create policy messages_member_send on public.group_messages
  for insert to authenticated
  with check (public.is_group_member(group_id) and sender_id = auth.uid());

-- Look up a group by invite code for the join flow (SECURITY DEFINER: reads
-- the invite without exposing the whole table; validates expiry/uses/revoked).
create or replace function public.resolve_invite(p_code text)
returns table(group_id uuid, group_name text)
language plpgsql security definer set search_path = public as $$
begin
  return query
  select g.id, g.name
  from public.group_invites i
  join public.groups g on g.id = i.group_id
  where i.code = p_code
    and not i.revoked
    and i.expires_at > now()
    and i.uses < i.max_uses;
end;
$$;

revoke execute on function public.resolve_invite from public, anon;
grant execute on function public.resolve_invite to authenticated;
