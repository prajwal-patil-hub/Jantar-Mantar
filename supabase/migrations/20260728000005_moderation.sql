-- Phase 4 — moderator tooling (ADR-27).
--
-- Trust promotion (ADR-25) is automatic, and automatic promotion needs a
-- manual brake. The counters only demote an account that gets things
-- *wrong*; they say nothing about an account that is accurate and hostile —
-- an infiltrator who reports true facts to build standing, then waits. An
-- admin has to be able to take the badge back that same minute, without
-- waiting for arithmetic.
--
-- Two functions, both admin-only, both audited:
--   * revoke_verifier  — drops an account to 'new' and HOLDS it there;
--   * restore_trust    — lifts the hold and recomputes from the counters.
--
-- The hold is the important half. Without it, revocation lasts exactly until
-- the next approved submission recomputes the tier and hands the badge
-- straight back.

alter table public.user_trust
  add column held boolean not null default false,
  add column hold_reason text check (char_length(hold_reason) <= 500);

-- A held account never gets promoted by the automatic path. bump_trust keeps
-- counting (so the record stays honest) but stops re-tiering.
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
  v_held boolean;
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
    returning tier, approved_count, rejected_count, held
    into old_tier, a, r, v_held;

  -- Counts still move; standing does not. An admin's hold outranks the
  -- arithmetic until an admin lifts it.
  if v_held then
    return;
  end if;

  new_tier := public.trust_tier_for(a, r);
  if new_tier is distinct from old_tier then
    update public.user_trust
      set tier = new_tier,
          promoted_at = case
            when new_tier <> 'new' then now() else null end
      where user_id = p_user;

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

-- A held account is not a verifier, whatever the tier column says.
create or replace function public.is_verifier()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(
    (select tier = 'verifier' and not held
       from public.user_trust where user_id = auth.uid()),
    false
  );
$$;

grant execute on function public.is_verifier() to authenticated;

create or replace function public.revoke_verifier(
  p_user uuid,
  p_reason text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  old_tier text;
begin
  if not public.is_admin() then
    raise exception 'admin role required';
  end if;
  if p_reason is null or char_length(trim(p_reason)) = 0 then
    raise exception 'reason required';
  end if;
  -- An admin removing their own standing is almost certainly a mistake, and
  -- the admin role does not come from this table anyway.
  if p_user = auth.uid() then
    raise exception 'cannot revoke your own standing';
  end if;

  insert into public.user_trust (user_id) values (p_user)
    on conflict (user_id) do nothing;

  update public.user_trust
    set tier = 'new',
        held = true,
        hold_reason = p_reason,
        promoted_at = null,
        updated_at = now()
    where user_id = p_user
    returning tier into old_tier;

  insert into public.audit_log
    (actor_id, action, entity, entity_id, before, after)
  values (
    auth.uid(), 'revoke_verifier', 'user', p_user::text,
    jsonb_build_object('tier', old_tier),
    jsonb_build_object('tier', 'new', 'held', true, 'reason', p_reason)
  );
end;
$$;

create or replace function public.restore_trust(p_user uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  a integer;
  r integer;
  new_tier text;
begin
  if not public.is_admin() then
    raise exception 'admin role required';
  end if;

  update public.user_trust
    set held = false, hold_reason = null, updated_at = now()
    where user_id = p_user
    returning approved_count, rejected_count into a, r;
  if not found then
    raise exception 'no standing to restore';
  end if;

  -- Lifting the hold recomputes from the record rather than restoring the
  -- old badge: the counters are the source of truth again.
  new_tier := public.trust_tier_for(a, r);
  update public.user_trust
    set tier = new_tier,
        promoted_at = case when new_tier <> 'new' then now() end
    where user_id = p_user;

  insert into public.audit_log
    (actor_id, action, entity, entity_id, before, after)
  values (
    auth.uid(), 'restore_trust', 'user', p_user::text,
    jsonb_build_object('held', true),
    jsonb_build_object('held', false, 'tier', new_tier)
  );
end;
$$;

revoke execute on function public.revoke_verifier from public, anon;
revoke execute on function public.restore_trust from public, anon;
grant execute on function public.revoke_verifier to authenticated;
grant execute on function public.restore_trust to authenticated;

-- Per-reporter history for the moderator screen. An admin can already read
-- every submission and every trust row by RLS; this only assembles them, so
-- it is SECURITY INVOKER — the caller's own permissions still apply and a
-- non-admin gets their own record, not someone else's.
create or replace function public.reporter_history(p_user uuid)
returns jsonb
language sql
stable
as $$
  select jsonb_build_object(
    'tier', coalesce((select tier from public.user_trust where user_id = p_user), 'new'),
    'held', coalesce((select held from public.user_trust where user_id = p_user), false),
    'hold_reason', (select hold_reason from public.user_trust where user_id = p_user),
    'approved', coalesce((select approved_count from public.user_trust where user_id = p_user), 0),
    'rejected', coalesce((select rejected_count from public.user_trust where user_id = p_user), 0),
    'recent', coalesce((
      select jsonb_agg(row_to_json(s))
      from (
        select id, state, reason, created_at, payload ->> 'category' as category,
               payload ->> 'status' as status
        from public.submissions
        where submitter_id = p_user
        order by created_at desc
        limit 20
      ) s
    ), '[]'::jsonb)
  );
$$;

revoke execute on function public.reporter_history from public, anon;
grant execute on function public.reporter_history to authenticated;
