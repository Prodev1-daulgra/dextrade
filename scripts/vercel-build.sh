#!/usr/bin/env bash
# Vercel production build — compiles Flutter web + bakes Supabase env into assets.
set -euo pipefail
cd "$(dirname "$0")/.."

echo "==> Dextrade Vercel build"

if [ -z "${SUPABASE_URL:-}" ] || [ -z "${SUPABASE_ANON_KEY:-}" ]; then
  echo "ERROR: Set SUPABASE_URL and SUPABASE_ANON_KEY in Vercel → Project → Settings → Environment Variables"
  exit 1
fi

FLUTTER_DIR="${PWD}/.flutter-sdk"
if [ ! -f "${FLUTTER_DIR}/bin/flutter" ]; then
  echo "==> Installing Flutter stable..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "${FLUTTER_DIR}"
fi
export PATH="${FLUTTER_DIR}/bin:${PATH}"

flutter --version
flutter config --enable-web --no-analytics
flutter pub get

# Write .env for flutter_dotenv (asset) before compile
cat > .env <<EOF
SUPABASE_URL=${SUPABASE_URL}
SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}
EOF

flutter build web --release --pwa-strategy=none \
  --dart-define=SUPABASE_URL="${SUPABASE_URL}" \
  --dart-define=SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY}"

mkdir -p build/web/assets
cp -f .env build/web/assets/.env

VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')
echo "{\"version\":\"${VERSION}\",\"builtAt\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"source\":\"vercel-build\"}" > build/web/version.json

if [ -f "web/app-release.apk" ]; then
  cp -f web/app-release.apk build/web/app-release.apk
fi

echo "==> Building marketing-web..."
cd marketing-web
npm install
npm run build
cd ..
mkdir -p build/web/landing
cp -r marketing-web/dist/* build/web/landing/

JS_SIZE=$(wc -c < build/web/main.dart.js)
echo "==> OK main.dart.js=${JS_SIZE} bytes, version=${VERSION}"

if [ ! -f build/web/assets/.env ]; then
  echo "ERROR: build/web/assets/.env missing after build"
  exit 1
fi
