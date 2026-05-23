#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SENTRY_ENV_FILE="${SENTRY_ENV_FILE:-$SCRIPT_DIR/sentry.env}"

if [ -f "$SENTRY_ENV_FILE" ]; then
  exec flutter "$@" --dart-define-from-file="$SENTRY_ENV_FILE"
fi

if [ -n "${SENTRY_DSN:-}" ]; then
  exec flutter "$@" --dart-define="SENTRY_DSN=$SENTRY_DSN"
fi

exec flutter "$@"
