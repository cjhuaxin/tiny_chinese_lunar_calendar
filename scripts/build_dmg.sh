#!/usr/bin/env bash
set -euo pipefail

APP_NAME="小小万年历"
VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}' | cut -d+ -f1)
DMG_NAME="${APP_NAME}-${VERSION}.dmg"
APP_PATH="build/macos/Build/Products/Release/${APP_NAME}.app"
STAGING_DIR="dist/dmg-staging"

flutter build macos --release --target lib/main_production.dart

if [[ ! -d "${APP_PATH}" ]]; then
  echo "❌ App not found: ${APP_PATH}" >&2
  exit 1
fi

rm -rf "${STAGING_DIR}"
mkdir -p dist "${STAGING_DIR}"
cp -R "${APP_PATH}" "${STAGING_DIR}/"
ln -sf /Applications "${STAGING_DIR}/Applications"

rm -f "dist/${DMG_NAME}"
hdiutil create \
  -volname "${APP_NAME}" \
  -srcfolder "${STAGING_DIR}" \
  -ov \
  -format UDZO \
  "dist/${DMG_NAME}"

rm -rf "${STAGING_DIR}"

echo "✅ DMG created: dist/${DMG_NAME}"
