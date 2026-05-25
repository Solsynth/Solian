#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# --- CONFIGURATION ---
APP_NAME="Solian"
CASK_NAME="solian"
RCLONE_REMOTE="r2" # Name of your rclone remote

S3_BUCKET="solsynth-files/solian" # Change to your actual bucket and path

# Load environment variables from .env
if [ -f ".env" ]; then
  set -a
  source .env
  set +a
else
  echo "❌ Error: .env file not found."
  exit 1
fi

DEVELOPER_ID="$DEVELOPER_ID"
APPLE_ID="$APPLE_ID"
TEAM_ID="$TEAM_ID"
APP_PASSWORD="$APP_PASSWORD"

# Validate required environment variables
if [ -z "$DEVELOPER_ID" ] || [ -z "$APPLE_ID" ] || [ -z "$TEAM_ID" ] || [ -z "$APP_PASSWORD" ]; then
  echo "❌ Error: Missing required environment variables in .env"
  echo "Required: DEVELOPER_ID, APPLE_ID, TEAM_ID, APP_PASSWORD"
  exit 1
fi

# Paths (Assumes homebrew-solian is cloned in the same parent directory)
FLUTTER_PROJECT_DIR=$(pwd)
TAP_DIR="../homebrew-solian"
CASK_FILE="$TAP_DIR/Casks/$CASK_NAME.rb"
PUBSPEC_FILE="pubspec.yaml"
# ---------------------

# 1. Automatically read version from pubspec.yaml
if [ ! -f "$PUBSPEC_FILE" ]; then
  echo "❌ Error: pubspec.yaml not found in the current directory."
  exit 1
fi

# Extract version line (e.g., "version: 1.0.0+4")
FLUTTER_VERSION=$(grep '^version: ' "$PUBSPEC_FILE" | awk '{print $2}')

if [ -z "$FLUTTER_VERSION" ]; then
  echo "❌ Error: Could not parse version from pubspec.yaml"
  exit 1
fi

# Convert "+" to "," for Homebrew compliance (e.g., 1.0.0+4 becomes 1.0.0,4)
HOMEBREW_VERSION=$(echo "$FLUTTER_VERSION" | tr '+' ',')

echo "🚀 Found Flutter version: $FLUTTER_VERSION"
echo "📦 Homebrew formatted version: $HOMEBREW_VERSION"

# Parse --no-build flag
SKIP_BUILD=false
for arg in "$@"; do
  case "$arg" in
  --no-build) SKIP_BUILD=true ;;
  esac
done

# 2. Build the Flutter macOS app (unless --no-build is set)
if [ "$SKIP_BUILD" = false ]; then
  echo "🔨 Building Flutter macOS app..."
  flutter pub get
  flutter build macos --release
else
  echo "⏭️ Skipping build (--no-build flag detected)..."
fi

#
# 3. Sign the app with Developer ID
APP_PATH="build/macos/Build/Products/Release/${APP_NAME}.app"

echo "🔏 Signing macOS app with Developer ID..."
codesign --deep --force --verbose \
  --sign "$DEVELOPER_ID" \
  --options runtime \
  "$APP_PATH"

# Verify signature

echo "🔍 Verifying code signature..."
codesign --verify --deep --strict --verbose=2 "$APP_PATH"

# Create temporary archive for notarization
TEMP_ZIP="${CASK_NAME}-notarization.zip"

echo "📦 Creating notarization archive..."
ditto -c -k --keepParent "$APP_PATH" "$TEMP_ZIP"

# Submit for notarization

echo "📝 Submitting app for notarization..."
xcrun notarytool submit "$TEMP_ZIP" \
  --apple-id "$APPLE_ID" \
  --team-id "$TEAM_ID" \
  --password "$APP_PASSWORD" \
  --wait

# Staple notarization ticket

echo "📎 Stapling notarization ticket..."
xcrun stapler staple "$APP_PATH"

# Final Gatekeeper verification

echo "🛡️ Running Gatekeeper verification..."
spctl -a -vvv "$APP_PATH"

# Remove temporary notarization archive
rm "$TEMP_ZIP"

# 4. Navigate to build outputs and compress
echo "🗜️ Packaging .app bundle into .tar.gz..."
BUILD_DIR="build/macos/Build/Products/Release"
# Use the clean version string without forbidden characters for the filename
FILE_SAFE_VERSION=$(echo "$FLUTTER_VERSION" | tr '+' '-')
ARCHIVE_NAME="${CASK_NAME}-macos-${FILE_SAFE_VERSION}.tar.gz"

cd "$BUILD_DIR"
tar -czvf "$FLUTTER_PROJECT_DIR/$ARCHIVE_NAME" "${APP_NAME}.app"
cd "$FLUTTER_PROJECT_DIR"

# 5. Calculate SHA-256 hash
echo "🔑 Calculating SHA-256 hash..."
SHA256=$(shasum -a 256 "$ARCHIVE_NAME" | awk '{print $1}')
echo "Hash: $SHA256"

# 6. Upload to S3 using rclone
echo "☁️ Uploading archive to S3 via rclone..."
rclone copyto "$ARCHIVE_NAME" "${RCLONE_REMOTE}:${S3_BUCKET}/$ARCHIVE_NAME" --progress

# Get the public S3 URL
DOWNLOAD_URL="https://raw.solsynth.dev/solian/$ARCHIVE_NAME"

# 7. Update local Homebrew Cask file
echo "📝 Updating Homebrew Cask file..."
if [ ! -f "$CASK_FILE" ]; then
  echo "❌ Error: Cask file not found at $CASK_FILE"
  exit 1
fi

# Update version, sha256, and url inside the Cask file using sed
sed -i '' "s|version \".*\"|version \"$HOMEBREW_VERSION\"|g" "$CASK_FILE"
sed -i '' "s|sha256 \".*\"|sha256 \"$SHA256\"|g" "$CASK_FILE"
sed -i '' "s|url \".*\"|url \"$DOWNLOAD_URL\"|g" "$CASK_FILE"

# 8. Commit and Push the Tap update
echo "🖥️ Committing and pushing Homebrew Tap updates..."
cd "$TAP_DIR"
git add "Casks/$CASK_NAME.rb"
git commit -m ":rocket: Launch $FLUTTER_VERSION"
git push origin main

# Clean up local archive
rm "$FLUTTER_PROJECT_DIR/$ARCHIVE_NAME"

echo "🎉 Done! Users can now run 'brew upgrade --cask $CASK_NAME' to fetch version $HOMEBREW_VERSION"
