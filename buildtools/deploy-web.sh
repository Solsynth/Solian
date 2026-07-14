#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# --- CONFIGURATION ---
PROJECT_NAME="solian"
PUBSPEC_FILE="pubspec.yaml"
# ---------------------

# 1. Automatically read version from pubspec.yaml
if [ ! -f "$PUBSPEC_FILE" ]; then
  echo "❌ Error: pubspec.yaml not found in the current directory."
  exit 1
fi

FLUTTER_VERSION=$(grep '^version: ' "$PUBSPEC_FILE" | awk '{print $2}')

if [ -z "$FLUTTER_VERSION" ]; then
  echo "❌ Error: Could not parse version from pubspec.yaml"
  exit 1
fi

echo "🚀 Found Flutter version: $FLUTTER_VERSION"

# 2. Build the Flutter web app
echo "🔨 Building Flutter web app..."
./buildtools/flutter-with-sentry.sh build web --base-href=/ --release

# 3. Deploy to Cloudflare Pages
echo "☁️ Deploying to Cloudflare Pages..."
BUILD_DIR="build/web"

cd "$BUILD_DIR"
wrangler pages deploy . --project-name="$PROJECT_NAME" --branch main
cd -

echo "🎉 Done! Web app version $FLUTTER_VERSION has been deployed to Cloudflare Pages."
