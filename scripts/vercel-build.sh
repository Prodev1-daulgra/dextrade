#!/usr/bin/env bash
# Builds Flutter web on Vercel (Linux). Required because Vercel only deploys static files.
set -euo pipefail

cd "$(dirname "$0")/.."

FLUTTER_DIR="${PWD}/.flutter-sdk"
if [ ! -f "${FLUTTER_DIR}/bin/flutter" ]; then
  echo "Installing Flutter stable..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "${FLUTTER_DIR}"
fi

export PATH="${FLUTTER_DIR}/bin:${PATH}"
flutter --version
flutter config --enable-web --no-analytics
flutter pub get
flutter build web --release

if [ -f "web/app-release.apk" ]; then
  cp -f web/app-release.apk build/web/app-release.apk
elif [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
  cp -f build/app/outputs/flutter-apk/app-release.apk build/web/app-release.apk
fi

echo "Web build ready: $(wc -c < build/web/main.dart.js) bytes main.dart.js"
