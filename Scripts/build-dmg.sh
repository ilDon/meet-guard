#!/usr/bin/env bash
set -euo pipefail

CONFIGURATION="${1:-release}"
APP_NAME="MeetGuard"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$ROOT_DIR/.build/app/$APP_NAME.app"
DIST_DIR="$ROOT_DIR/.build/dist"
DMG_PATH="$DIST_DIR/$APP_NAME.dmg"
DMG_ROOT="$ROOT_DIR/.build/dmg-root"

cd "$ROOT_DIR"
"$ROOT_DIR/Scripts/build-app.sh" "$CONFIGURATION" >/dev/null

rm -rf "$DMG_ROOT" "$DMG_PATH"
mkdir -p "$DMG_ROOT" "$DIST_DIR"

cp -R "$APP_DIR" "$DMG_ROOT/$APP_NAME.app"
ln -s /Applications "$DMG_ROOT/Applications"

hdiutil create \
    -volname "$APP_NAME" \
    -srcfolder "$DMG_ROOT" \
    -ov \
    -format UDZO \
    "$DMG_PATH" >/dev/null

echo "$DMG_PATH"
