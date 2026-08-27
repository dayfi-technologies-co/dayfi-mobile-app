#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
ASSETS="$ROOT/ios/Runner/Assets.xcassets"
SRC="$ASSETS/AppIcon.appiconset"

echo "→ Regenerating launcher icons (Android + iOS AppIcon)…"
dart run flutter_launcher_icons -f flutter_launcher_icons.yaml

echo "→ Regenerating native splash (Android + iOS)…"
dart run flutter_native_splash:create --path=flutter_native_splash.yaml

echo "→ Syncing iOS flavor icon sets from AppIcon…"
for SET in devAppIcon pilotAppIcon prodAppIcon; do
  DEST="$ASSETS/${SET}.appiconset"
  [[ -d "$DEST" ]] || continue
  for png in "$SRC"/*.png; do
    name="$(basename "$png")"
    if [[ -f "$DEST/$name" ]]; then
      cp "$png" "$DEST/$name"
    fi
  done
done

echo "✓ Branding assets refreshed for Android and iOS."
