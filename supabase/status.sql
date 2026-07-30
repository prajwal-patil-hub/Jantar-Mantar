-- Which migrations are applied to this project?
--
-- Paste into the Supabase SQL Editor and Run. Every column that reads `true`
-- is already applied; run the `false` ones, in filename order, and nothing
-- else. Checks for the object each migration actually creates rather than
-- trusting a changelog, so it cannot drift from reality.

select
  to_regclass('public.facilities')      is not null as "1_init",
  to_regclass('public.group_messages')  is not null as "2_groups",
  to_regclass('public.user_trust')      is not null as "3_trust",
  to_regproc('public.try_corroborate')  is not null as "4_corroboration",
  to_regproc('public.revoke_verifier')  is not null as "5_moderation",
  exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name = 'device_keys'
      and column_name = 'signing_public_key'
  ) as "6_signing_keys";
