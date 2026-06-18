#!/usr/bin/env bash
set -euo pipefail

CONFIGURATION="${1:-debug}"
APP_NAME="MeetGuard"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/.build/$CONFIGURATION"
APP_DIR="$ROOT_DIR/.build/app/$APP_NAME.app"

cd "$ROOT_DIR"
swift build -c "$CONFIGURATION"

rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"

cp "$ROOT_DIR/Resources/Info.plist" "$APP_DIR/Contents/Info.plist"
cp "$ROOT_DIR/Resources/MeetGuardIcon.icns" "$APP_DIR/Contents/Resources/MeetGuardIcon.icns"
cp "$ROOT_DIR/Resources/MeetGuardIcon.png" "$APP_DIR/Contents/Resources/MeetGuardIcon.png"
cp "$ROOT_DIR/Resources/MeetGuardMenuBarIcon.png" "$APP_DIR/Contents/Resources/MeetGuardMenuBarIcon.png"
cp "$BUILD_DIR/$APP_NAME" "$APP_DIR/Contents/MacOS/$APP_NAME"
printf "APPL????" > "$APP_DIR/Contents/PkgInfo"

echo "$APP_DIR"
