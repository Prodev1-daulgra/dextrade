-- Dextrade micro-features: preferences, watchlist, in-app notifications, paper orders
-- Run after dextrade_mvp_schema.sql

-- ─── User preferences (per-account UI + terminal state) ───
create table if not exists public.user_preferences (
  user_email text primary key references public.users(email) on delete cascade,
  hide_balance boolean not null default false,
  haptics_enabled boolean not null default true,
  default_timeframe text not null default '15M',
  last_trade_pair text not null default 'BTC',
  notify_trades boolean not null default true,
  notify_deposits boolean not null default true,
  mirror_sort text not null default 'roi' check (mirror_sort in ('roi','win_rate','followers')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ─── Watchlist (trade desk favorites) ───
create table if not exists public.watchlist (
  id uuid primary key default uuid_generate_v4(),
  user_email text not null references public.users(email) on delete cascade,
  symbol text not null,
  source text not null default 'db' check (source in ('db','coingecko')),
  sort_order int not null default 0,
  created_at timestamptz not null default now(),
  unique (user_email, symbol)
);

-- ─── In-app notification feed (push-style history) ───
create table if not exists public.app_notifications (
  id uuid primary key default uuid_generate_v4(),
  user_email text not null references public.users(email) on delete cascade,
  title text not null,
  body text not null,
  kind text not null default 'info' check (kind in ('info','trade','deposit','mirror','system')),
  is_read boolean not null default false,
  meta jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_app_notifications_user_created
  on public.app_notifications (user_email, created_at desc);

-- ─── Paper trade orders (terminal log persisted) ───
create table if not exists public.trade_orders (
  id uuid primary key default uuid_generate_v4(),
  user_email text not null references public.users(email) on delete cascade,
  pair_symbol text not null,
  side text not null check (side in ('LONG','SHORT')),
  order_type text not null default 'market' check (order_type in ('market','limit')),
  price numeric(24,8) not null,
  size numeric(24,8) not null,
  leverage int not null default 1 check (leverage between 1 and 125),
  margin_usd numeric(20,8) not null default 0,
  status text not null default 'open' check (status in ('open','closed','cancelled')),
  pnl_usd numeric(20,8),
  closed_at timestamptz,
  created_at timestamptz not null default now()
);

-- Extend transactions + copy_trades for richer vault/mirror UX
alter table public.transactions add column if not exists network text;
alter table public.transactions add column if not exists meta jsonb not null default '{}'::jsonb;

alter table public.copy_trades add column if not exists risk_cap_pct numeric(5,2) default 100;
alter table public.copy_trades add column if not exists auto_detach_on_drawdown boolean not null default false;

-- Triggers
do $$ begin
  create trigger trg_user_preferences_updated_at before update on public.user_preferences
  for each row execute function public.set_updated_at();
exception when duplicate_object then null; end $$;

-- Ensure preferences row on profile creation
create or replace function public.ensure_user_preferences_row()
returns trigger language plpgsql security definer as $$
begin
  insert into public.user_preferences (user_email)
  values (new.email)
  on conflict (user_email) do nothing;
  return new;
end; $$;

do $$ begin
  create trigger trg_users_preferences
  after insert on public.users
  for each row execute function public.ensure_user_preferences_row();
exception when duplicate_object then null; end $$;

-- RPC: upsert preferences
create or replace function public.upsert_user_preferences(
  p_hide_balance boolean default null,
  p_haptics_enabled boolean default null,
  p_default_timeframe text default null,
  p_last_trade_pair text default null,
  p_notify_trades boolean default null,
  p_notify_deposits boolean default null,
  p_mirror_sort text default null
)
returns public.user_preferences
language plpgsql security definer as $$
declare
  v_email text := public.auth_email();
  v_row public.user_preferences;
begin
  if v_email is null then raise exception 'Not authenticated'; end if;

  insert into public.user_preferences (user_email)
  values (v_email)
  on conflict (user_email) do nothing;

  update public.user_preferences set
    hide_balance = coalesce(p_hide_balance, hide_balance),
    haptics_enabled = coalesce(p_haptics_enabled, haptics_enabled),
    default_timeframe = coalesce(p_default_timeframe, default_timeframe),
    last_trade_pair = coalesce(p_last_trade_pair, last_trade_pair),
    notify_trades = coalesce(p_notify_trades, notify_trades),
    notify_deposits = coalesce(p_notify_deposits, notify_deposits),
    mirror_sort = coalesce(p_mirror_sort, mirror_sort),
    updated_at = now()
  where user_email = v_email
  returning * into v_row;

  return v_row;
end; $$;

-- RPC: toggle watchlist symbol
create or replace function public.toggle_watchlist(p_symbol text, p_source text default 'db')
returns boolean
language plpgsql security definer as $$
declare
  v_email text := public.auth_email();
  v_exists boolean;
begin
  if v_email is null then raise exception 'Not authenticated'; end if;

  select exists(
    select 1 from public.watchlist where user_email = v_email and symbol = upper(p_symbol)
  ) into v_exists;

  if v_exists then
    delete from public.watchlist where user_email = v_email and symbol = upper(p_symbol);
    return false;
  else
    insert into public.watchlist (user_email, symbol, source)
    values (v_email, upper(p_symbol), p_source);
    return true;
  end if;
end; $$;

-- RPC: push in-app notification
create or replace function public.push_app_notification(
  p_title text,
  p_body text,
  p_kind text default 'info',
  p_meta jsonb default '{}'::jsonb
)
returns uuid
language plpgsql security definer as $$
declare
  v_email text := public.auth_email();
  v_id uuid;
begin
  if v_email is null then raise exception 'Not authenticated'; end if;

  insert into public.app_notifications (user_email, title, body, kind, meta)
  values (v_email, p_title, p_body, p_kind, p_meta)
  returning id into v_id;

  return v_id;
end; $$;

-- RLS
alter table public.user_preferences enable row level security;
alter table public.watchlist enable row level security;
alter table public.app_notifications enable row level security;
alter table public.trade_orders enable row level security;

drop policy if exists prefs_own on public.user_preferences;
create policy prefs_own on public.user_preferences
for all using (user_email = auth_email()) with check (user_email = auth_email());

drop policy if exists watchlist_own on public.watchlist;
create policy watchlist_own on public.watchlist
for all using (user_email = auth_email()) with check (user_email = auth_email());

drop policy if exists notifications_own on public.app_notifications;
create policy notifications_own on public.app_notifications
for select using (user_email = auth_email());
create policy notifications_insert_own on public.app_notifications
for insert with check (user_email = auth_email());
create policy notifications_update_own on public.app_notifications
for update using (user_email = auth_email());

drop policy if exists trade_orders_own on public.trade_orders;
create policy trade_orders_own on public.trade_orders
for all using (user_email = auth_email()) with check (user_email = auth_email());

drop policy if exists trade_orders_admin on public.trade_orders;
create policy trade_orders_admin on public.trade_orders
for all using (is_admin());

-- Backfill preferences for existing users
insert into public.user_preferences (user_email)
select email from public.users
on conflict (user_email) do nothing;
