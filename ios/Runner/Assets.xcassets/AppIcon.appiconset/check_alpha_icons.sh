#!/bin/zsh
# Check all PNGs in AppIcon.appiconset for alpha channel (transparency)
cd "/Users/mac/Desktop/dayfi_send_app/ios/Runner/Assets.xcassets/AppIcon.appiconset"
echo "Checking for alpha channel in app icons..."
for f in *.png; do
  if [[ $(sips -g alpha "$f" | grep -c 'alpha: yes') -gt 0 ]]; then
    echo "❌ $f has transparency (alpha channel)"
  else
    echo "✅ $f is solid (no alpha channel)"
  fi
done
