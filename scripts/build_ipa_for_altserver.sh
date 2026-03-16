#!/usr/bin/env zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SCHEME="FitNotes"
PROJECT_PATH="$ROOT_DIR/FitNotes.xcodeproj"
DERIVED_PATH="$ROOT_DIR/.DerivedData-iphoneos"
OUTPUT_DIR="$ROOT_DIR/build"
APP_PATH="$DERIVED_PATH/Build/Products/Release-iphoneos/FitNotes.app"
PAYLOAD_DIR="$OUTPUT_DIR/Payload"
VERSION_LABEL="0.1.0"
IPA_PATH="$OUTPUT_DIR/FitNotesIOS_${VERSION_LABEL}.ipa"

export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"

mkdir -p "$OUTPUT_DIR"
rm -rf "$PAYLOAD_DIR" "$IPA_PATH"

echo "[1/3] Building iphoneos app (unsigned)..."
xcodebuild \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME" \
  -configuration Release \
  -sdk iphoneos \
  -derivedDataPath "$DERIVED_PATH" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  build > "$OUTPUT_DIR/xcodebuild-iphoneos.log"

if [[ ! -d "$APP_PATH" ]]; then
  echo "Error: built app not found at $APP_PATH"
  exit 1
fi

echo "[2/3] Packaging Payload..."
mkdir -p "$PAYLOAD_DIR"
cp -R "$APP_PATH" "$PAYLOAD_DIR/"

echo "[3/3] Creating IPA..."
(
  cd "$OUTPUT_DIR"
  /usr/bin/zip -qry "$(basename "$IPA_PATH")" Payload
)

echo "Done: $IPA_PATH"
echo "Use this IPA in AltServer/AltStore. AltServer will sign it with your Apple ID during sideload."
