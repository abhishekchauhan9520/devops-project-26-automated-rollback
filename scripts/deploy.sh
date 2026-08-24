#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-}"
MODE="${2:-normal}"
[[ -n "$VERSION" ]] || { echo "usage: $0 <version> [normal|force-fail]" >&2; exit 64; }

STATE_DIR="${STATE_DIR:-.release-state}"
mkdir -p "$STATE_DIR"
source "$(dirname "$0")/state.sh"

previous=""
if previous="$(known_good 2>/dev/null)"; then
  :
else
  previous="none"
fi
record_current "$VERSION"
record_event "deploy-start" "$VERSION"

if [[ "$MODE" == "force-fail" ]]; then
  record_event "health-failed" "$VERSION"
  if [[ "$previous" != "none" ]]; then
    "$PWD/scripts/rollback.sh" "$previous"
  fi
  exit 1
fi

record_known_good "$VERSION"
record_event "deploy-success" "$VERSION"
printf 'deployment succeeded: %s\n' "$VERSION"
