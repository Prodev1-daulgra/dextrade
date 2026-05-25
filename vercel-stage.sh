#!/bin/sh
set -eu
OUT=".vercel-output"
rm -rf "$OUT"
mkdir -p "$OUT"
if [ -f build/web/main.dart.js ]; then
  cp -r build/web/. "$OUT/"
elif [ -f main.dart.js ]; then
  find . -mindepth 1 -maxdepth 1 ! -name .vercel-output -exec cp -r {} "$OUT/" \;
else
  echo ERROR missing main.dart.js
  pwd
  ls -la
  exit 1
fi
test -f "$OUT/main.dart.js"
echo STAGED_OK
