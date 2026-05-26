#!/bin/bash

set -e

PUB_CACHE="${HOME}/.pub-cache/hosted/pub.dev"

echo "Patching Flutter plugin compileSdk versions to 36..."

# Groovy DSL
find "$PUB_CACHE" -type f -name "*.gradle" | while read -r file; do
  sed -i '' \
    -E 's/compileSdkVersion[[:space:]]+[0-9]+/compileSdkVersion 36/g' \
    "$file"

  sed -i '' \
    -E 's/compileSdk[[:space:]]+[=:][[:space:]]*[0-9]+/compileSdk = 36/g' \
    "$file"
done

# Kotlin DSL
find "$PUB_CACHE" -type f -name "*.gradle.kts" | while read -r file; do
  sed -i '' \
    -E 's/compileSdk[[:space:]]*=[[:space:]]*[0-9]+/compileSdk = 36/g' \
    "$file"

  sed -i '' \
    -E 's/compileSdkVersion\([[:space:]]*[0-9]+[[:space:]]*\)/compileSdkVersion(36)/g' \
    "$file"
done

echo "Done."
