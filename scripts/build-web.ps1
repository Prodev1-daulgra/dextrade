# Dextrade — canonical web release build (run before every Vercel push)
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot\..

Write-Host "==> Dextrade web release build" -ForegroundColor Cyan

if (-not (Test-Path ".env")) {
  Write-Error "Missing .env in project root. Copy .env.example and set SUPABASE_URL + SUPABASE_ANON_KEY."
}

$version = (Get-Content pubspec.yaml | Select-String "^version:").ToString().Split(" ")[1].Trim()
$stamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

Write-Host "==> flutter build web --release (no service worker — avoids stale cache)"
flutter build web --release --pwa-strategy=none

Write-Host "==> bundle .env into build/web/assets (required on Vercel static host)"
New-Item -ItemType Directory -Force -Path "build\web\assets" | Out-Null
Copy-Item -Force ".env" "build\web\assets\.env"

Write-Host "==> APK for /app-release.apk"
if (Test-Path "web\app-release.apk") {
  Copy-Item -Force "web\app-release.apk" "build\web\app-release.apk"
} elseif (Test-Path "build\app\outputs\flutter-apk\app-release.apk") {
  Copy-Item -Force "build\app\outputs\flutter-apk\app-release.apk" "build\web\app-release.apk"
  Copy-Item -Force "build\app\outputs\flutter-apk\app-release.apk" "web\app-release.apk"
} else {
  Write-Warning "No APK found. Run: flutter build apk --release"
}

@{
  version = $version
  builtAt = $stamp
  commit  = (git rev-parse --short HEAD 2>$null)
} | ConvertTo-Json | Set-Content -Encoding utf8 "build\web\version.json"

$jsSize = (Get-Item "build\web\main.dart.js").Length
if (-not (Test-Path "build\web\assets\.env")) {
  Write-Error "Post-build check failed: build/web/assets/.env missing"
}
if ($jsSize -lt 1000000) {
  Write-Error "Post-build check failed: main.dart.js too small ($jsSize bytes)"
}

Write-Host "OK  version=$version  main.dart.js=$([math]::Round($jsSize/1MB,2)) MB" -ForegroundColor Green
Write-Host "Next: git add build/web web/app-release.apk && git commit && git push"
