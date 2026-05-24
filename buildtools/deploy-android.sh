#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# --- CONFIGURATION ---
RCLONE_REMOTE="r2"
S3_BUCKET="solsyth-files/solian"

# Paths
FLUTTER_PROJECT_DIR=$(pwd)
PUBSPEC_FILE="pubspec.yaml"
# ---------------------

# 1. Automatically read version from pubspec.yaml
if [ ! -f "$PUBSPEC_FILE" ]; then
  echo "Error: pubspec.yaml not found in the current directory."
  exit 1
fi

FLUTTER_VERSION=$(grep '^version: ' "$PUBSPEC_FILE" | awk '{print $2}')

if [ -z "$FLUTTER_VERSION" ]; then
  echo "Error: Could not parse version from pubspec.yaml"
  exit 1
fi

echo "Found Flutter version: $FLUTTER_VERSION"

# 2. Build the Flutter Android APK
echo "Building Flutter Android APK..."
flutter pub get
flutter build apk --release

# 3. Upload APK to S3 using rclone (keep original filename)
APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
APK_NAME="app-release.apk"

echo "Uploading APK to S3 via rclone..."
rclone copyto "$APK_PATH" "${RCLONE_REMOTE}:${S3_BUCKET}/$APK_NAME" --progress --overwrite

echo "Done! APK uploaded to ${S3_BUCKET}/${APK_NAME}"
