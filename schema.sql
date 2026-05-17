-- =============================================================================
-- DEXTRADE - Master Schema "Institutional Obsidian"
-- Platform: Supabase (PostgreSQL)
-- Description: Consolidated definitive schema for crypto & derivative trading,
--              plus full Stocks vertical with sector tagging and stock portfolio.
--              Includes CopyTrading, Options, Futures, and Auth extensions.
-- =============================================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 2. ENUMS
CREATE TYPE public.transaction_type AS ENUM (
  'deposit', 'withdrawal', 'buy', 'sell',
  'stock_buy', 'stock_sell',
  'copy_profit', 'futures', 'options'
);

CREATE TYPE public.transaction_status AS ENUM (
  'pending', 'approved', 'rejected', 'completed'
);

CREATE TYPE public.risk_level AS ENUM (
  'low', 'medium', 'high'
);

CREATE TYPE public.user_role AS ENUM (
  'user', 'admin'
);

-- 3. TABLES

-- Core User System
CREATE TABLE public.users (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  auth_id         UUID UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  email           TEXT NOT NULL UNIQUE,
  full_name       TEXT,
  wallet_address  TEXT,
  role            public.user_role NOT NULL DEFAULT 'user',
  status          TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'suspended')),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.user_balances (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_email        TEXT NOT NULL UNIQUE REFERENCES public.users(email) ON DELETE CASCADE,
  balance_usd       NUMERIC(20, 8) NOT NULL DEFAULT 0 CHECK (balance_usd >= 0),
  total_invested    NUMERIC(20, 8) NOT NULL DEFAULT 0 CHECK (total_invested >= 0),
  total_profit_loss NUMERIC(20, 8) NOT NULL DEFAULT 0,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Crypto Market Data
CREATE TABLE public.cryptocurrencies (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  symbol      TEXT NOT NULL UNIQUE,
  name        TEXT NOT NULL,
  price       NUMERIC(24, 8) NOT NULL DEFAULT 0 CHECK (price >= 0),
  change_24h  NUMERIC(10, 4) NOT NULL DEFAULT 0,
  market_cap  NUMERIC(30, 2) DEFAULT 0,
  volume_24h  NUMERIC(30, 2) DEFAULT 0,
  icon_color  TEXT NOT NULL DEFAULT '#A855F7',
  is_active   BOOLEAN NOT NULL DEFAULT TRUE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Stocks Market Data
CREATE TABLE public.stocks (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  symbol      TEXT NOT NULL UNIQUE,
  name        TEXT NOT NULL,
  price       NUMERIC(24, 8) NOT NULL DEFAULT 0 CHECK (price >= 0),
  change_24h  NUMERIC(10, 4) NOT NULL DEFAULT 0,
  market_cap  NUMERIC(30, 2) DEFAULT 0,
  volume_24h  NUMERIC(30, 2) DEFAULT 0,
  sector      TEXT NOT NULL DEFAULT 'Technology',
  exchange    TEXT NOT NULL DEFAULT 'NASDAQ',
  icon_color  TEXT NOT NULL DEFAULT '#7C3AED',
  is_active   BOOLEAN NOT NULL DEFAULT TRUE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Standard Crypto Trading & Portfolio
CREATE TABLE public.portfolio (
  id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_email     TEXT NOT NULL REFERENCES public.users(email) ON DELETE CASCADE,
  crypto_symbol  TEXT NOT NULL REFERENCES public.cryptocurrencies(symbol) ON UPDATE CASCADE,
  amount         NUMERIC(30, 8) NOT NULL DEFAULT 0 CHECK (amount >= 0),
  avg_buy_price  NUMERIC(24, 8) NOT NULL DEFAULT 0 CHECK (avg_buy_price >= 0),
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_email, crypto_symbol)
);

-- Stock Portfolio
CREATE TABLE public.stock_portfolio (
  id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_email     TEXT NOT NULL REFERENCES public.users(email) ON DELETE CASCADE,
  stock_symbol   TEXT NOT NULL REFERENCES public.stocks(symbol) ON UPDATE CASCADE,
  shares         NUMERIC(30, 8) NOT NULL DEFAULT 0 CHECK (shares >= 0),
  avg_buy_price  NUMERIC(24, 8) NOT NULL DEFAULT 0 CHECK (avg_buy_price >= 0),
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_email, stock_symbol)
);

-- Unified Transaction Ledger
CREATE TABLE public.transactions (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_email      TEXT NOT NULL REFERENCES public.users(email) ON DELETE CASCADE,
  type            public.transaction_type NOT NULL,
  amount          NUMERIC(20, 8) NOT NULL CHECK (amount > 0),
  crypto_symbol   TEXT REFERENCES public.cryptocurrencies(symbol) ON UPDATE CASCADE,
  stock_symbol    TEXT REFERENCES public.stocks(symbol) ON UPDATE CASCADE,
  crypto_amount   NUMERIC(30, 8) CHECK (crypto_amount >= 0),
  shares          NUMERIC(30, 8) CHECK (shares >= 0),
  status          public.transaction_status NOT NULL DEFAULT 'pending',
  notes           TEXT,
  wallet_address  TEXT,
  reviewed_by     TEXT REFERENCES public.users(email),
  reviewed_at     TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Copy Trading System
CREATE TABLE public.copy_traders (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  trader_name         TEXT NOT NULL,
  specialty           TEXT,
  total_profit_pct    NUMERIC(10, 4) NOT NULL DEFAULT 0,
  win_rate            NUMERIC(5, 2) NOT NULL DEFAULT 0 CHECK (win_rate BETWEEN 0 AND 100),
  total_trades        INTEGER NOT NULL DEFAULT 0 CHECK (total_trades >= 0),
  followers           INTEGER NOT NULL DEFAULT 0 CHECK (followers >= 0),
  profit_split_pct    NUMERIC(5, 2) NOT NULL DEFAULT 20 CHECK (profit_split_pct BETWEEN 0 AND 100),
  min_allocation      NUMERIC(20, 2) NOT NULL DEFAULT 100 CHECK (min_allocation >= 0),
  is_approved         BOOLEAN NOT NULL DEFAULT FALSE,
  status              TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
  risk_level          public.risk_level NOT NULL DEFAULT 'medium',
  avatar_color        TEXT NOT NULL DEFAULT '#A855F7',
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.copy_trades (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_email       TEXT NOT NULL REFERENCES public.users(email) ON DELETE CASCADE,
  trader_id        UUID NOT NULL REFERENCES public.copy_traders(id) ON DELETE CASCADE,
  trader_name      TEXT NOT NULL,
  allocation       NUMERIC(20, 8) NOT NULL CHECK (allocation > 0),
  profit_loss      NUMERIC(20, 8) NOT NULL DEFAULT 0,
  profit_loss_pct  NUMERIC(10, 4) NOT NULL DEFAULT 0,
  status           public.transaction_status NOT NULL DEFAULT 'pending',
  is_active        BOOLEAN NOT NULL DEFAULT FALSE,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_email, trader_id)
);

-- Derivative Trading (Futures & Options)
CREATE TABLE public.futures_positions (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_email        TEXT NOT NULL REFERENCES public.users(email) ON DELETE CASCADE,
  crypto_symbol     TEXT NOT NULL REFERENCES public.cryptocurrencies(symbol) ON UPDATE CASCADE,
  side              TEXT NOT NULL CHECK (side IN ('long', 'short')),
  leverage          INTEGER NOT NULL DEFAULT 1 CHECK (leverage >= 1),
  margin_usd        NUMERIC(20, 8) NOT NULL CHECK (margin_usd > 0),
  entry_price       NUMERIC(24, 8) NOT NULL CHECK (entry_price > 0),
  liquidation_price NUMERIC(24, 8) NOT NULL CHECK (liquidation_price >= 0),
  size_usd          NUMERIC(24, 8) NOT NULL CHECK (size_usd > 0),
  unrealized_pnl    NUMERIC(20, 8) NOT NULL DEFAULT 0,
  status            TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'closed', 'liquidated')),
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.options_positions (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_email        TEXT NOT NULL REFERENCES public.users(email) ON DELETE CASCADE,
  underlying_symbol TEXT NOT NULL REFERENCES public.cryptocurrencies(symbol) ON UPDATE CASCADE,
  type              TEXT NOT NULL CHECK (type IN ('call', 'put')),
  strike_price      NUMERIC(24, 8) NOT NULL CHECK (strike_price > 0),
  expiration_date   TIMESTAMPTZ NOT NULL,
  contracts         NUMERIC(20, 8) NOT NULL CHECK (contracts > 0),
  premium_paid_usd  NUMERIC(20, 8) NOT NULL CHECK (premium_paid_usd > 0),
  status            TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'closed', 'expired_worthless', 'exercised')),
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Platform Utility Tables
CREATE TABLE public.platform_settings (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  key         TEXT NOT NULL UNIQUE,
  value       TEXT NOT NULL,
  label       TEXT,
  updated_by  TEXT REFERENCES public.users(email),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.balance_adjustments (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_email      TEXT NOT NULL REFERENCES public.users(email) ON DELETE CASCADE,
  amount          NUMERIC(20, 8) NOT NULL,
  type            TEXT NOT NULL CHECK (type IN ('add', 'subtract')),
  reason          TEXT,
  admin_email     TEXT REFERENCES public.users(email),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.email_notifications (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  recipient_email TEXT NOT NULL,
  template_type   TEXT NOT NULL,
  subject         TEXT NOT NULL,
  body_html       TEXT NOT NULL,
  related_tx_id   UUID REFERENCES public.transactions(id) ON DELETE SET NULL,
  status          TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'sent', 'failed', 'bounced')),
  sent_at         TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. REALTIME PUBLICATIONS
alter publication supabase_realtime add table public.user_balances;
alter publication supabase_realtime add table public.transactions;

-- 5. UPDATED_AT TRIGGER LOGIC
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END; $$;

DO $$ DECLARE t TEXT; BEGIN
  FOREACH t IN ARRAY ARRAY[
    'users','user_balances','cryptocurrencies','stocks','portfolio','stock_portfolio',
    'transactions','copy_traders','copy_trades','platform_settings',
    'email_notifications','futures_positions','options_positions'
  ] LOOP
    EXECUTE format('CREATE OR REPLACE TRIGGER trg_%I_updated_at BEFORE UPDATE ON public.%I FOR EACH ROW EXECUTE FUNCTION set_updated_at()', t, t);
  END LOOP;
END; $$;

-- 6. SECURITY HELPERS
CREATE OR REPLACE FUNCTION public.auth_email()
RETURNS TEXT LANGUAGE sql SECURITY DEFINER STABLE AS $$
  SELECT auth.jwt() ->> 'email' $$;

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN LANGUAGE sql SECURITY DEFINER STABLE AS $$
  SELECT EXISTS (SELECT 1 FROM public.users WHERE auth_id = auth.uid() AND role = 'admin') $$;

-- 7. AUTH TRIGGER (Automatically create user and balance on signup)
CREATE OR REPLACE FUNCTION public.handle_new_auth_user() RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO public.users (auth_id, email, full_name) VALUES (NEW.id, NEW.email, COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email,'@',1)));
  INSERT INTO public.user_balances (user_email) VALUES (NEW.email);
  RETURN NEW;
END; $$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_auth_user();

-- 8. ROW LEVEL SECURITY (Enabled but highly permissive for MVP rapid testing)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_balances ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cryptocurrencies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.portfolio ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stock_portfolio ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.copy_traders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.copy_trades ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.platform_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.email_notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.balance_adjustments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.futures_positions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.options_positions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable ALL for everyone" ON public.users FOR ALL USING (true);
CREATE POLICY "Enable ALL for everyone" ON public.user_balances FOR ALL USING (true);
CREATE POLICY "Enable ALL for everyone" ON public.cryptocurrencies FOR ALL USING (true);
CREATE POLICY "Enable ALL for everyone" ON public.stocks FOR ALL USING (true);
CREATE POLICY "Enable ALL for everyone" ON public.portfolio FOR ALL USING (true);
CREATE POLICY "Enable ALL for everyone" ON public.stock_portfolio FOR ALL USING (true);
CREATE POLICY "Enable ALL for everyone" ON public.transactions FOR ALL USING (true);
CREATE POLICY "Enable ALL for everyone" ON public.copy_traders FOR ALL USING (true);
CREATE POLICY "Enable ALL for everyone" ON public.copy_trades FOR ALL USING (true);
CREATE POLICY "Enable ALL for everyone" ON public.platform_settings FOR ALL USING (true);
CREATE POLICY "Enable ALL for everyone" ON public.email_notifications FOR ALL USING (true);
CREATE POLICY "Enable ALL for everyone" ON public.balance_adjustments FOR ALL USING (true);
CREATE POLICY "Enable ALL for everyone" ON public.futures_positions FOR ALL USING (true);
CREATE POLICY "Enable ALL for everyone" ON public.options_positions FOR ALL USING (true);

-- 9. SEED DATA

-- Cryptocurrencies
INSERT INTO public.cryptocurrencies (symbol, name, price, change_24h, market_cap, volume_24h, icon_color) VALUES
('BTC',  'Bitcoin',        67842.50,  2.43,  1320000000000, 38400000000, '#F7931A'),
('ETH',  'Ethereum',        3521.80, -0.82,   424000000000, 18200000000, '#627EEA'),
('SOL',  'Solana',           182.60,  5.34,    82000000000,  3100000000, '#9945FF')
ON CONFLICT (symbol) DO NOTHING;

-- Stocks
INSERT INTO public.stocks (symbol, name, price, change_24h, market_cap, volume_24h, sector, exchange, icon_color) VALUES
('AAPL',  'Apple Inc.',              189.30,  0.84,  2950000000000,  62000000, 'Technology',  'NASDAQ', '#555555'),
('MSFT',  'Microsoft Corp.',         415.20,  1.12,  3080000000000,  24000000, 'Technology',  'NASDAQ', '#00A4EF'),
('NVDA',  'NVIDIA Corp.',            875.40,  3.21,  2160000000000,  48000000, 'Technology',  'NASDAQ', '#76B900')
ON CONFLICT (symbol) DO NOTHING;

-- Copy Traders
INSERT INTO public.copy_traders (trader_name, specialty, total_profit_pct, win_rate, total_trades, followers, profit_split_pct, min_allocation, is_approved, risk_level, avatar_color) VALUES
('Quantum Alpha', 'Derivatives', 142.5, 84.5, 1250, 450, 20.0, 100.0, TRUE, 'medium', '#A855F7'),
('Apex Yield', 'DeFi / Stocks', 88.4, 92.1, 840, 120, 15.0, 50.0, TRUE, 'low', '#7C3AED')
ON CONFLICT DO NOTHING;
