#!/usr/bin/env bash
set -euo pipefail

# Vercel's Node build image does not include the Flutter SDK.
flutter_sdk_dir="${TMPDIR:-/tmp}/kabadiwala-flutter-sdk"
git clone --depth 1 --branch stable https://github.com/flutter/flutter.git "$flutter_sdk_dir"
export PATH="$flutter_sdk_dir/bin:$PATH"

flutter config --enable-web
flutter pub get
flutter build web --release \
  --dart-define=API_BASE_URL=https://kabadiwala-backend-rho.vercel.app \
  --dart-define=SUPABASE_URL=https://cngpzareirwfwqqkaaxk.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNuZ3B6YXJlaXJ3ZndxcWthYXhrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA2MTIyNTUsImV4cCI6MjEwNjE4ODI1NX0.lKumVV3wzf6sAadJtW72kTbxWet7Tj7j3LyPEa4lKx8
