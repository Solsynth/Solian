#!/bin/bash

set -e

PUB_CACHE="${HOME}/.pub-cache/hosted/pub.dev"

replace_in_file() {
  local expression="$1"
  local file="$2"

  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' -E "$expression" "$file"
  else
    sed -i -E "$expression" "$file"
  fi
}

echo "Patching Flutter plugin compileSdk versions to 36..."

# Groovy DSL
find "$PUB_CACHE" -type f -name "*.gradle" | while read -r file; do
  replace_in_file 's/compileSdkVersion[[:space:]]+[0-9]+/compileSdkVersion 36/g' "$file"

  replace_in_file 's/compileSdk[[:space:]]+[=:][[:space:]]*[0-9]+/compileSdk = 36/g' "$file"
done

# Kotlin DSL
find "$PUB_CACHE" -type f -name "*.gradle.kts" | while read -r file; do
  replace_in_file 's/compileSdk[[:space:]]*=[[:space:]]*[0-9]+/compileSdk = 36/g' "$file"

  replace_in_file 's/compileSdkVersion\([[:space:]]*[0-9]+[[:space:]]*\)/compileSdkVersion(36)/g' "$file"
done

echo "Done."
