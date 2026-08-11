#!/usr/bin/env bash
set -euo pipefail

# Tests DistributionCenter's upload-url request and the subsequent direct
# presigned PUT. It intentionally does not attach the test object to a release.
# Use a disposable version and upload key; the test can leave a small orphaned
# object and draft release behind.

: "${DISTRIBUTION_API_BASE_URL:?Set DISTRIBUTION_API_BASE_URL, including /api}"
: "${DISTRIBUTION_PRODUCT_ID:?Set DISTRIBUTION_PRODUCT_ID}"

BASE_URL="${DISTRIBUTION_API_BASE_URL%/}"
PRODUCT_ID="$DISTRIBUTION_PRODUCT_ID"
VERSION="${DISTRIBUTION_TEST_VERSION:-0.0.0-upload-test-$(date +%s)}"

if [[ -z "${DISTRIBUTION_UPLOAD_KEY:-}" ]]; then
  read -r -s -p 'Distribution upload key: ' DISTRIBUTION_UPLOAD_KEY
  printf '\n'
fi
: "${DISTRIBUTION_UPLOAD_KEY:?Distribution upload key is required}"

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/distribution-upload-test.XXXXXX")"
trap 'rm -rf "$TMP_DIR"' EXIT

FILE="$TMP_DIR/distribution-upload-test.bin"
RESPONSE="$TMP_DIR/upload-url-response"
HEADERS="$TMP_DIR/put-headers"
BODY="$TMP_DIR/put-body"

printf 'DistributionCenter upload test\n' > "$FILE"
SHA256="$(shasum -a 256 "$FILE" | awk '{print $1}')"
SIZE="$(wc -c < "$FILE" | tr -d '[:space:]')"

REQUEST_BODY="$(cat <<JSON
{
  "version": "$VERSION",
  "channel": "stable",
  "file_name": "distribution-upload-test.bin",
  "mime_type": "application/octet-stream",
  "sha256": "$SHA256"
}
JSON
)"

printf 'Requesting presigned upload URL for version %s...\n' "$VERSION"
POST_STATUS="$(curl --silent --show-error \
  --output "$RESPONSE" \
  --write-out '%{http_code}' \
  --request POST \
  --header "Authorization: Bearer $DISTRIBUTION_UPLOAD_KEY" \
  --header 'Content-Type: application/json' \
  --data "$REQUEST_BODY" \
  "$BASE_URL/products/$PRODUCT_ID/artifacts/upload-url")"

if [[ ! "$POST_STATUS" =~ ^2 ]]; then
  printf 'Upload URL request failed (%s):\n' "$POST_STATUS" >&2
  cat "$RESPONSE" >&2
  exit 1
fi

UPLOAD_URL="$(jq -r '.upload_url // empty' "$RESPONSE")"
OBJECT_KEY="$(jq -r '.object_key // empty' "$RESPONSE")"

if [[ -z "$UPLOAD_URL" || -z "$OBJECT_KEY" ]]; then
  printf 'DistributionCenter returned an incomplete upload response.\n' >&2
  jq 'del(.upload_url)' "$RESPONSE" >&2 || cat "$RESPONSE" >&2
  exit 1
fi

UPLOAD_ORIGIN="$(printf '%s' "$UPLOAD_URL" | sed -E 's#^(https?://[^/]+).*$#\1#')"
printf 'Presigned upload origin: %s\n' "$UPLOAD_ORIGIN"
printf 'Object key: %s\n' "$OBJECT_KEY"
printf 'Uploading %s bytes...\n' "$SIZE"

PUT_STATUS="$(curl --silent --show-error \
  --output "$BODY" \
  --dump-header "$HEADERS" \
  --write-out '%{http_code}' \
  --request PUT \
  --header 'Content-Type: application/octet-stream' \
  --header "Content-Length: $SIZE" \
  --header "x-amz-meta-sha256: $SHA256" \
  --upload-file "$FILE" \
  "$UPLOAD_URL")"

awk 'BEGIN { IGNORECASE = 1 } /^HTTP\// || /^cf-ray:/ || /^content-type:/ { print }' "$HEADERS"

if [[ ! "$PUT_STATUS" =~ ^2 ]]; then
  printf 'Artifact PUT failed (%s):\n' "$PUT_STATUS" >&2
  cat "$BODY" >&2
  exit 1
fi

printf 'Artifact PUT succeeded (%s).\n' "$PUT_STATUS"
printf 'The test object was uploaded but not attached to the release.\n'
