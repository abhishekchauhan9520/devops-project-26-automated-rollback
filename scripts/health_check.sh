#!/usr/bin/env bash
set -euo pipefail

URL="${1:-${HEALTH_URL:-http://127.0.0.1:8080/health}}"
TIMEOUT="${TIMEOUT_SECONDS:-5}"

command -v curl >/dev/null 2>&1 || { echo "curl is required" >&2; exit 127; }
curl --fail --silent --show-error --max-time "$TIMEOUT" "$URL" >/dev/null
