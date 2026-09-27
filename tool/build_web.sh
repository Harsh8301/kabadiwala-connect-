#!/usr/bin/env bash
set -euo pipefail

# Vercel's Node build image does not include the Flutter SDK.
flutter_sdk_dir="${TMPDIR:-/tmp}/kabadiwala-flutter-sdk"
git clone --depth 1 --branch stable https://github.com/flutter/flutter.git "$flutter_sdk_dir"
export PATH="$flutter_sdk_dir/bin:$PATH"

flutter config --enable-web
flutter pub get
flutter build web --release \
  --dart-define=API_BASE_URL=https://kabadiwala-backend.vercel.app
