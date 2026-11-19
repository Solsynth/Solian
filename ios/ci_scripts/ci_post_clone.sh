#!/bin/sh

# Fail this script if any subcommand fails.
set -e

# The default execution directory is ios/ci_scripts/. Move to the repository root.
cd "$CI_PRIMARY_REPOSITORY_PATH"

echo "=== Installing Flutter SDK ==="
# `stable` is a moving branch: at 3.50.0 its Dart 3.14.0 violates the
# `sdks: dart: ">=3.13.0 <3.14.0"` pin in pubspec.lock, and
# liquid_glass_renderer only publishes `<3.14.0`. Build the exact release the
# repo pins in .mise.toml instead, so Xcode Cloud and `mise exec` agree.
FLUTTER_VERSION=$(sed -n 's/^flutter *= *"\([0-9][^"]*\)".*$/\1/p' .mise.toml | head -n 1)
if [ -z "$FLUTTER_VERSION" ]; then
  echo "Could not read the Flutter version from .mise.toml"
  exit 1
fi
echo "Pinned Flutter version: $FLUTTER_VERSION"

# A shallow clone of the release tag resolves to "<version>-0-g<hash>", which
# the Flutter tool accepts (a branch clone would report a non-release version).
git clone https://github.com/flutter/flutter.git --depth 1 -b "$FLUTTER_VERSION" "$HOME/flutter"
export PATH="$PATH:$HOME/flutter/bin"
flutter --version

# Pre-cache iOS artifacts and fetch dependencies
flutter precache --ios
flutter pub get

echo "=== Installing CocoaPods ==="
# Disable homebrew auto-updates to save CI time
HOMEBREW_NO_AUTO_UPDATE=1 brew install cocoapods

# Install iOS pods
echo "=== Running Pod Install ==="
cd ios
pod install --repo-update

# Return to root and generate configurations
cd "$CI_PRIMARY_REPOSITORY_PATH"
flutter build ios --config-only

echo "=== Script finished successfully ==="
exit 0
