#!/bin/sh
# Stage Flutter web for Vercel — works whether Root Directory is "." or "build/web".
set -eu

OUT=".vercel-output"
rm -rf "$OUT"
mkdir -p "$OUT"

if [ -f "build/web/main.dart.js" ]; then
  echo "Found bundle at build/web/ (repo root)"
  cp -r build/web/. "$OUT/"
elif [ -f "main.dart.js" ]; then
  echo "Found bundle at project root (Vercel Root Directory = build/web)"
  cp -r . "$OUT/"
else
  echo "ERROR: Flutter web bundle not found."
  echo "pwd=$(pwd)"
  ls -la
  ls -la build 2>/dev/null || true
  exit 1
fi

echo "Staged $(wc -c < "$OUT/main.dart.js") bytes -> $OUT/main.dart.js"
