#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export STATE_DIR="$TMP/state"

bash -n "$ROOT/scripts/state.sh"
bash -n "$ROOT/scripts/health_check.sh"
bash -n "$ROOT/scripts/deploy.sh"
bash -n "$ROOT/scripts/rollback.sh"

bash "$ROOT/scripts/deploy.sh" v1.0.0
[[ "$(bash "$ROOT/scripts/state.sh" get-good)" == "v1.0.0" ]]

if bash "$ROOT/scripts/deploy.sh" v2.0.0-broken force-fail; then
  echo "expected failed deployment" >&2
  exit 1
fi
[[ "$(bash "$ROOT/scripts/state.sh" get-good)" == "v1.0.0" ]]
[[ "$(bash "$ROOT/scripts/state.sh" get-current)" == "v1.0.0" ]]
grep -q '|rollback|' "$TMP/state/events.log"

if bash "$ROOT/scripts/rollback.sh" >/tmp/rollback-noop.out; then
  [[ "$(cat /tmp/rollback-noop.out)" == *"rollback completed"* ]]
else
  echo "rollback command failed" >&2
  exit 1
fi

echo "Project 26 rollback tests passed."
