# Deploying Dextrade to Vercel

Vercel publishes the **compiled** Flutter app in `build/web/` (not Dart source).

**No build script** — avoids `exit 127` / schema errors. Push `build/web/main.dart.js` with your code.

## Vercel settings (pick ONE)

### A — Recommended

| Setting | Value |
|--------|--------|
| **Root Directory** | *(leave empty)* |
| **Build Command** | *(override OFF — use repo `vercel.json`)* |
| **Output Directory** | *(override OFF)* |

Repo root `vercel.json` uses `"outputDirectory": "build/web"`.

### B — If Root Directory is `build/web`

Set **Root Directory** to `build/web` in Vercel → Settings → General.

`build/web/vercel.json` uses `"outputDirectory": "."`.

Do **not** set a custom Build Command.

## After UI changes

```bash
flutter build web --release
copy web\app-release.apk build\web\app-release.apk
git add build/web
git commit -m "chore: update web build"
git push
```

## Live URLs

- App: `https://dextrade-tau.vercel.app/landing`
- APK: `https://dextrade-tau.vercel.app/app-release.apk`

Hard refresh after deploy: **Ctrl+Shift+R**.
