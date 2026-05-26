# Supabase SQL — run order

Run these **once**, in order, in the Supabase SQL Editor (new project or first setup).

| Step | File | Required? |
|------|------|-----------|
| 1 | `dextrade_mvp_schema.sql` | **Yes** — tables, RLS, auth trigger, crypto seed |
| 2 | `ensure_profile_v1.sql` | **Yes** — `ensure_profile_v1()` RPC (login/profile fix) |
| 3 | `micro_features_v1.sql` | **Yes** for watchlist, preferences, notifications, paper orders |

Do **not** run only `micro_features_v1.sql` on an empty database — it depends on `public.users`, `set_updated_at()`, and `auth_email()` from step 1.

## Already ran MVP schema earlier?

If `dextrade_mvp_schema.sql` is already applied, run only:

1. `ensure_profile_v1.sql` (safe to re-run)
2. `micro_features_v1.sql` (safe to re-run; uses `if not exists` / `drop policy if exists`)

## Optional

- Root `schema.sql` — legacy; prefer `supabase/dextrade_mvp_schema.sql` for this app.
