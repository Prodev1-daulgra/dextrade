-- Dextrade MVP schema (mapped from salarn emper/schema_v2_master.sql)
-- Target: Supabase Postgres
-- This is the minimum set needed for the current Flutter app:
-- - auth -> profile row creation
-- - balances + transactions + copy trading tables
-- - RLS policies aligned to email ownership (and admin override)
--
-- Apply in Supabase SQL editor.

create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";

-- ENUMS
do $$ begin
  create type public.transaction_type as enum (
    'deposit', 'withdrawal', 'buy', 'sell', 'copy_profit', 'futures', 'options'
  );
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.transaction_status as enum ('pending', 'approved', 'rejected', 'completed');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.risk_level as enum ('low', 'medium', 'high');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.user_role as enum ('user', 'admin');
exception when duplicate_object then null; end $$;

-- TABLES
create table if not exists public.users (
  id uuid primary key default uuid_generate_v4(),
  auth_id uuid unique references auth.users(id) on delete cascade,
  email text not null unique,
  full_name text,
  wallet_address text,
  role public.user_role not null default 'user',
  status text not null default 'active' check (status in ('active','suspended')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.user_balances (
  id uuid primary key default uuid_generate_v4(),
  user_email text not null unique references public.users(email) on delete cascade,
  balance_usd numeric(20,8) not null default 0 check (balance_usd >= 0),
  total_invested numeric(20,8) not null default 0 check (total_invested >= 0),
  total_profit_loss numeric(20,8) not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.cryptocurrencies (
  id uuid primary key default uuid_generate_v4(),
  symbol text not null unique,
  name text not null,
  price numeric(24,8) not null default 0 check (price >= 0),
  change_24h numeric(10,4) not null default 0,
  market_cap numeric(30,2) default 0,
  volume_24h numeric(30,2) default 0,
  icon_color text not null default '#F7931A',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.portfolio (
  id uuid primary key default uuid_generate_v4(),
  user_email text not null references public.users(email) on delete cascade,
  crypto_symbol text not null references public.cryptocurrencies(symbol) on update cascade,
  amount numeric(30,8) not null default 0 check (amount >= 0),
  avg_buy_price numeric(24,8) not null default 0 check (avg_buy_price >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_email, crypto_symbol)
);

create table if not exists public.transactions (
  id uuid primary key default uuid_generate_v4(),
  user_email text not null references public.users(email) on delete cascade,
  type public.transaction_type not null,
  amount numeric(20,8) not null check (amount > 0),
  crypto_symbol text references public.cryptocurrencies(symbol) on update cascade,
  crypto_amount numeric(30,8) check (crypto_amount >= 0),
  status public.transaction_status not null default 'pending',
  notes text,
  wallet_address text,
  reviewed_by text references public.users(email),
  reviewed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.copy_traders (
  id uuid primary key default uuid_generate_v4(),
  trader_name text not null,
  specialty text,
  total_profit_pct numeric(10,4) not null default 0,
  win_rate numeric(5,2) not null default 0 check (win_rate between 0 and 100),
  total_trades integer not null default 0 check (total_trades >= 0),
  followers integer not null default 0 check (followers >= 0),
  profit_split_pct numeric(5,2) not null default 20 check (profit_split_pct between 0 and 100),
  min_allocation numeric(20,2) not null default 100 check (min_allocation >= 0),
  is_approved boolean not null default false,
  status text not null default 'active' check (status in ('active','inactive')),
  risk_level public.risk_level not null default 'medium',
  avatar_color text not null default '#6366f1',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.copy_trades (
  id uuid primary key default uuid_generate_v4(),
  user_email text not null references public.users(email) on delete cascade,
  trader_id uuid not null references public.copy_traders(id) on delete cascade,
  trader_name text not null,
  allocation numeric(20,8) not null check (allocation > 0),
  profit_loss numeric(20,8) not null default 0,
  profit_loss_pct numeric(10,4) not null default 0,
  status public.transaction_status not null default 'pending',
  is_active boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_email, trader_id)
);

-- UPDATED_AT trigger
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end; $$;

do $$ begin
  create trigger trg_users_updated_at before update on public.users
  for each row execute function public.set_updated_at();
exception when duplicate_object then null; end $$;
do $$ begin
  create trigger trg_user_balances_updated_at before update on public.user_balances
  for each row execute function public.set_updated_at();
exception when duplicate_object then null; end $$;
do $$ begin
  create trigger trg_cryptocurrencies_updated_at before update on public.cryptocurrencies
  for each row execute function public.set_updated_at();
exception when duplicate_object then null; end $$;
do $$ begin
  create trigger trg_portfolio_updated_at before update on public.portfolio
  for each row execute function public.set_updated_at();
exception when duplicate_object then null; end $$;
do $$ begin
  create trigger trg_transactions_updated_at before update on public.transactions
  for each row execute function public.set_updated_at();
exception when duplicate_object then null; end $$;
do $$ begin
  create trigger trg_copy_traders_updated_at before update on public.copy_traders
  for each row execute function public.set_updated_at();
exception when duplicate_object then null; end $$;
do $$ begin
  create trigger trg_copy_trades_updated_at before update on public.copy_trades
  for each row execute function public.set_updated_at();
exception when duplicate_object then null; end $$;

-- Helper functions
create or replace function public.auth_email()
returns text language sql security definer stable as $$
  select auth.jwt() ->> 'email' $$;

create or replace function public.is_admin()
returns boolean language sql security definer stable as $$
  select exists (
    select 1 from public.users
    where auth_id = auth.uid() and role = 'admin'
  ) $$;

-- AUTH TRIGGER (profile + balance creation)
create or replace function public.handle_new_auth_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.users (auth_id, email, full_name, role)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email,'@',1)),
    case when new.email = 'tonyokezie10@gmail.com' then 'admin'::public.user_role else 'user'::public.user_role end
  )
  on conflict (email) do update set auth_id = excluded.auth_id;

  insert into public.user_balances (user_email)
  values (new.email)
  on conflict (user_email) do nothing;
  return new;
end; $$;

do $$ begin
  create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_auth_user();
exception when duplicate_object then null; end $$;

-- RLS
alter table public.users enable row level security;
alter table public.user_balances enable row level security;
alter table public.cryptocurrencies enable row level security;
alter table public.portfolio enable row level security;
alter table public.transactions enable row level security;
alter table public.copy_traders enable row level security;
alter table public.copy_trades enable row level security;

drop policy if exists users_select_own on public.users;
create policy users_select_own on public.users
for select using (email = auth_email() or is_admin());

drop policy if exists users_update_own on public.users;
create policy users_update_own on public.users
for update using (email = auth_email()) with check (email = auth_email());

drop policy if exists users_admin_all on public.users;
create policy users_admin_all on public.users
for all using (is_admin());

drop policy if exists balances_own on public.user_balances;
create policy balances_own on public.user_balances
for select using (user_email = auth_email());

drop policy if exists balances_admin_all on public.user_balances;
create policy balances_admin_all on public.user_balances
for all using (is_admin());

drop policy if exists cryptos_read_active on public.cryptocurrencies;
create policy cryptos_read_active on public.cryptocurrencies
for select using (is_active = true or is_admin());

drop policy if exists cryptos_admin_all on public.cryptocurrencies;
create policy cryptos_admin_all on public.cryptocurrencies
for all using (is_admin());

drop policy if exists portfolio_own on public.portfolio;
create policy portfolio_own on public.portfolio
for select using (user_email = auth_email());

drop policy if exists portfolio_admin_all on public.portfolio;
create policy portfolio_admin_all on public.portfolio
for all using (is_admin());

drop policy if exists txns_own_read on public.transactions;
create policy txns_own_read on public.transactions
for select using (user_email = auth_email() or is_admin());

drop policy if exists txns_own_insert on public.transactions;
create policy txns_own_insert on public.transactions
for insert with check (user_email = auth_email());

drop policy if exists txns_admin_all on public.transactions;
create policy txns_admin_all on public.transactions
for all using (is_admin());

drop policy if exists traders_read_active on public.copy_traders;
create policy traders_read_active on public.copy_traders
for select using (status = 'active' or is_approved = true or is_admin());

drop policy if exists traders_admin_all on public.copy_traders;
create policy traders_admin_all on public.copy_traders
for all using (is_admin());

drop policy if exists copy_trades_own on public.copy_trades;
create policy copy_trades_own on public.copy_trades
for select using (user_email = auth_email() or is_admin());

drop policy if exists copy_trades_own_insert on public.copy_trades;
create policy copy_trades_own_insert on public.copy_trades
for insert with check (user_email = auth_email());

drop policy if exists copy_trades_admin_all on public.copy_trades;
create policy copy_trades_admin_all on public.copy_trades
for all using (is_admin());

-- Seed minimal crypto market data so the Flutter dashboard doesn't look dead.
insert into public.cryptocurrencies (symbol, name, price, change_24h, market_cap, volume_24h, icon_color, is_active)
values
('BTC','Bitcoin', 67842.50, 2.43, 1320000000000, 38400000000, '#F7931A', true),
('ETH','Ethereum', 3521.80, -0.82, 424000000000, 18200000000, '#627EEA', true),
('SOL','Solana', 182.60, 5.34, 82000000000, 3100000000, '#9945FF', true),
('BNB','BNB', 608.40, 1.21, 91000000000, 2100000000, '#F3BA2F', true),
('XRP','XRP', 0.62, -1.44, 34000000000, 1800000000, '#0085C0', true)
on conflict (symbol) do nothing;

