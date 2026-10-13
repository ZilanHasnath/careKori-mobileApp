#!/usr/bin/env bash
set -euo pipefail

flutter create --org com.carekori --project-name carekori --platforms android,ios .

MANIFEST="android/app/src/main/AndroidManifest.xml"
if ! grep -q "android.permission.INTERNET" "$MANIFEST"; then
  sed -i 's#<application#<uses-permission android:name="android.permission.INTERNET"/>\n    <application#' "$MANIFEST"
fi

flutter pub get
