-- Dextrade MVP: ensure_profile_v1 RPC
-- Creates missing `public.users` + `public.user_balances` rows for the current auth user.
--
-- Apply this in Supabase SQL editor if your auth trigger wasn't installed.
-- After applying, the Flutter app will call this automatically on login/register.

create or replace function public.ensure_profile_v1()
returns void
language plpgsql
security definer
as $$
declare
  v_email text;
  v_full_name text;
  v_uid uuid;
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'Not authenticated';
  end if;

  v_email := (auth.jwt() ->> 'email');
  if v_email is null or length(v_email) = 0 then
    raise exception 'Email missing in JWT';
  end if;

  v_full_name :=
    coalesce(auth.jwt() -> 'user_metadata' ->> 'full_name', split_part(v_email, '@', 1));

  insert into public.users (auth_id, email, full_name, role)
  values (
    v_uid,
    v_email,
    v_full_name,
    case when v_email = 'tonyokezie10@gmail.com' then 'admin'::public.user_role else 'user'::public.user_role end
  )
  on conflict (email) do update
    set auth_id = excluded.auth_id,
        full_name = coalesce(public.users.full_name, excluded.full_name);

  insert into public.user_balances (user_email)
  values (v_email)
  on conflict (user_email) do nothing;
end;
$$;

-- Permissions: allow any authenticated user to call it
grant execute on function public.ensure_profile_v1() to authenticated;

