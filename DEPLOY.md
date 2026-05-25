# Deploying Dextrade to Vercel

Vercel serves the **compiled** Flutter web app from `build/web/`, not your Dart source.

## Why the site looked unchanged after push

If you only committed `lib/` changes, GitHub still had the **old** `build/web/main.dart.js`. The live site at [dextrade-tau.vercel.app](https://dextrade-tau.vercel.app) reads that file.

## Option A — Vercel (recommended)

`vercel.json` deploys the **committed** folder `build/web/` (no Flutter install on Vercel).

**Vercel Root Directory** can be empty **or** `build/web` — `vercel-stage.sh` detects both. Recommended: leave Root Directory **empty** (repo root).

Push any commit that includes an updated `build/web/main.dart.js`.

## Option B — Refresh the web bundle before push

```bash
flutter build web --release
copy build\app\outputs\flutter-apk\app-release.apk build\web\app-release.apk
```

Then commit **all** of `build/web/` and push.

## Optional — Build Flutter on Vercel

Only if you need CI to compile Dart (slower). Use `scripts/vercel-build.sh` from repo root with LF line endings, or set Root Directory to `.`.

## After deploy

- Open: `https://dextrade-tau.vercel.app/landing` (path URLs, not `#/landing`)
- Hard refresh: `Ctrl+Shift+R` or clear site data (old service worker cache)
- APK: `https://dextrade-tau.vercel.app/app-release.apk`
