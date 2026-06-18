#!/usr/bin/env bash
set -euo pipefail

APP_NAME="MeetGuard"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INFO_PLIST="$ROOT_DIR/Resources/Info.plist"
DMG_PATH="$ROOT_DIR/.build/dist/$APP_NAME.dmg"

usage() {
    cat <<EOF
Usage:
  Scripts/release.sh [VERSION]

Examples:
  make release
  make release VERSION=1.2.0
  Scripts/release.sh 1.2.0

Creates a release commit, tag, GitHub Release, and uploads the DMG.
Requires: gh auth login
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

cd "$ROOT_DIR"

if ! command -v gh >/dev/null 2>&1; then
    echo "error: GitHub CLI is required. Install it from https://cli.github.com/" >&2
    exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
    echo "error: GitHub CLI is not authenticated. Run: gh auth login" >&2
    exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
    echo "error: working tree must be clean before publishing a release." >&2
    echo "Commit or stash your changes first." >&2
    exit 1
fi

CURRENT_VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$INFO_PLIST")"
VERSION="${1:-${VERSION:-}}"
COMMITTED=0

cleanup_on_error() {
    if [[ "$COMMITTED" == "0" ]]; then
        git checkout -- "$INFO_PLIST" >/dev/null 2>&1 || true
    fi
}
trap cleanup_on_error ERR

if [[ -z "$VERSION" ]]; then
    read -r -p "Version to release [$CURRENT_VERSION]: " VERSION
    VERSION="${VERSION:-$CURRENT_VERSION}"
fi

if [[ ! "$VERSION" =~ ^[0-9]+(\.[0-9]+){1,2}(-[A-Za-z0-9.-]+)?$ ]]; then
    echo "error: invalid version '$VERSION'. Use a value like 1.2.0." >&2
    exit 1
fi

TAG="v$VERSION"
CURRENT_BRANCH="$(git branch --show-current)"

if [[ -z "$CURRENT_BRANCH" ]]; then
    echo "error: cannot release from a detached HEAD." >&2
    exit 1
fi

if git rev-parse "$TAG" >/dev/null 2>&1; then
    echo "error: tag $TAG already exists locally." >&2
    exit 1
fi

if git ls-remote --exit-code --tags origin "refs/tags/$TAG" >/dev/null 2>&1; then
    echo "error: tag $TAG already exists on origin." >&2
    exit 1
fi

BUILD_NUMBER="$(date +%Y%m%d%H%M)"

plutil -replace CFBundleShortVersionString -string "$VERSION" "$INFO_PLIST"
plutil -replace CFBundleVersion -string "$BUILD_NUMBER" "$INFO_PLIST"

swift test
"$ROOT_DIR/Scripts/build-dmg.sh" release >/dev/null

git add "$INFO_PLIST"
git commit -m "Release $TAG"
COMMITTED=1
git tag -a "$TAG" -m "$APP_NAME $TAG"
git push origin "$CURRENT_BRANCH"
git push origin "$TAG"

gh release create "$TAG" \
    "$DMG_PATH#${APP_NAME}-${VERSION}.dmg" \
    --title "$APP_NAME $VERSION" \
    --notes "Release $VERSION"

echo "Published $APP_NAME $VERSION"
echo "DMG: $DMG_PATH"
