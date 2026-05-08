#!/usr/bin/env bash

set -euo pipefail

# Usage:
# ./convert-webp.sh assets/images
#
# Optional env:
# QUALITY=85 DELETE_ORIGINAL=1 ./convert-webp.sh assets/images

TARGET_DIR="${1:-.}"
QUALITY="${QUALITY:-85}"
DELETE_ORIGINAL="${DELETE_ORIGINAL:-0}"

if ! command -v cwebp >/dev/null 2>&1; then
  echo "cwebp not found."
  echo "Install via:"
  echo "  brew install webp"
  exit 1
fi

find "$TARGET_DIR" \
  \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) |
  while read -r file; do

    output="${file%.*}.webp"

    if [ -f "$output" ]; then
      echo "Skipping existing: $output"
      continue
    fi

    echo "Converting: $file -> $output"

    cwebp \
      -q "$QUALITY" \
      "$file" \
      -o "$output"

    if [ "$DELETE_ORIGINAL" = "1" ]; then
      rm "$file"
      echo "Deleted original: $file"
    fi
  done

echo "Done."
