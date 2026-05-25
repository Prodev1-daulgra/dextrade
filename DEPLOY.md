# Deploying Dextrade to Vercel

Vercel serves the **compiled** Flutter web app from `build/web/`, not your Dart source.

## Why the site looked unchanged after push

If you only committed `lib/` changes, GitHub still had the **old** `build/web/main.dart.js`. The live site at [dextrade-tau.vercel.app](https://dextrade-tau.vercel.app) reads that file.

## Option A — Automatic (recommended)

`vercel.json` runs `scripts/vercel-build.sh` on each deploy (installs Flutter on Vercel and runs `flutter build web`).

Push any commit; wait for the Vercel build to finish (first build ~8–15 min).

## Option B — Manual (GitHub Desktop)

```bash
flutter build web --release
copy build\app\outputs\flutter-apk\app-release.apk build\web\app-release.apk
```

Then commit **all** of `build/web/` and push.

## After deploy

- Open: `https://dextrade-tau.vercel.app/landing` (path URLs, not `#/landing`)
- Hard refresh: `Ctrl+Shift+R` or clear site data (old service worker cache)
- APK: `https://dextrade-tau.vercel.app/app-release.apk`
