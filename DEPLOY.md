# Deploying Dextrade (engineering checklist)

## Why the site showed only “Connecting Engine”

The HTML splash is **not** the app — it shows until Flutter paints the first frame.

Production was deploying `build/web/` **without** `assets/.env`, so `main()` crashed before startup. You only saw the loader.

**Fixed in code:** `AppEnv` + boot error screen + build scripts that always bake `.env` into `build/web/assets/`.

---

## Path A — Vercel builds on push (recommended)

1. **Vercel → Settings → Environment Variables** (Production + Preview):
   - `SUPABASE_URL` = your Supabase project URL  
   - `SUPABASE_ANON_KEY` = your anon key  

2. **Vercel → Settings → General:**
   - Root Directory: **empty** (repo root)
   - Build Command: **leave empty** (uses repo `vercel.json` → `bash scripts/vercel-build.sh`)
   - Output Directory: **leave empty** (`build/web` from `vercel.json`)

3. Push to `main`. Vercel runs Flutter on Linux and outputs fresh `build/web/`.

4. Verify deploy:
   - https://dextrade-tau.vercel.app/version.json — must show current `version` + `builtAt`
   - https://dextrade-tau.vercel.app/landing — must show new marketing UI (not stuck splash)
   - Hard refresh: **Ctrl+Shift+R**

---

## Path B — Pre-built `build/web` in git (GitHub Desktop)

Use when Vercel does not run Flutter (or you build locally):

```powershell
cd c:\Users\hp\Desktop\Dexglow\projects\dextrade
.\scripts\build-web.ps1
git add build/web web/app-release.apk
git commit -m "chore: web release $(Get-Date -Format yyyy-MM-dd)"
git push
```

**Required:** `build-web.ps1` copies `.env` → `build/web/assets/.env`.  
If you skip this script, production **will** break again.

Force-add env if gitignored:

```powershell
git add -f build/web/assets/.env
```

---

## Android APK

```powershell
flutter build apk --release
copy build\app\outputs\flutter-apk\app-release.apk web\app-release.apk
.\scripts\build-web.ps1   # also copies APK into build/web
```

Download: https://dextrade-tau.vercel.app/app-release.apk

---

## Supabase SQL (run once, in order)

| # | File |
|---|------|
| 1 | `supabase/dextrade_mvp_schema.sql` |
| 2 | `supabase/ensure_profile_v1.sql` |
| 3 | `supabase/micro_features_v1.sql` |

Not `micro_features_v1.sql` alone on an empty database.

---

## Release checklist (every ship)

- [ ] `flutter analyze` — no errors  
- [ ] `.\scripts\build-web.ps1` — passes post-build checks  
- [ ] `/version.json` on live site matches `pubspec.yaml` version  
- [ ] `/landing` loads past splash  
- [ ] Login works (schema applied)  
- [ ] APK URL downloads ~54MB file (not placeholder)
