-- Run in Supabase SQL Editor. The client must never receive service_role_key.
create extension if not exists pgcrypto;

create table if not exists public.auth_attempt_logs (
  id bigint generated always as identity primary key,
  email_hash text not null,
  attempted_at timestamptz not null default now(),
  ip_hint text
);

alter table public.profiles enable row level security;
alter table public.auth_attempt_logs enable row level security;
alter table public.locations enable row level security;
alter table public.museums_import enable row level security;

drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own" on public.profiles for select to authenticated using (id = auth.uid());
drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own" on public.profiles for update to authenticated using (id = auth.uid()) with check (id = auth.uid());
drop policy if exists "locations_read_authenticated" on public.locations;
create policy "locations_read_authenticated" on public.locations for select to authenticated using (true);
drop policy if exists "museums_read_authenticated" on public.museums_import;
create policy "museums_read_authenticated" on public.museums_import for select to authenticated using (true);

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public
as $$
begin
  insert into public.profiles (id, display_name, created_at, updated_at)
  values (
    new.id,
    coalesce(nullif(new.raw_user_meta_data->>'display_name', ''), 'user_' || substr(new.id::text, 1, 8)),
    now(),
    now()
  ) on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();

create index if not exists profiles_email_idx on public.profiles (lower(email));
create index if not exists auth_attempt_logs_time_idx on public.auth_attempt_logs (attempted_at desc);

create or replace function public.log_auth_failure(attempt_email text)
returns void language plpgsql security definer set search_path = public
as $$
begin
  insert into public.auth_attempt_logs (email_hash)
  values (encode(digest(lower(trim(attempt_email)), 'sha256'), 'hex'));
end;
$$;
revoke all on function public.log_auth_failure(text) from public;
grant execute on function public.log_auth_failure(text) to anon, authenticated;

-- Configure Supabase Auth dashboard: minimum password length 8, leaked-password
-- protection enabled, email confirmation enabled, and rate limits enabled.