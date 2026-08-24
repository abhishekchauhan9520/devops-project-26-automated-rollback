#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-}"
MODE="${2:-normal}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
STATE_DIR="${STATE_DIR:-$ROOT_DIR/.release-state}"

[[ -n "$VERSION" ]] || { echo "usage: $0 <version> [normal|force-fail]" >&2; exit 64; }
source "$SCRIPT_DIR/state.sh"

previous=""
if previous="$(known_good 2>/dev/null)"; then :; else previous="none"; fi
record_current "$VERSION"
record_event "deploy-start" "$VERSION"

if [[ "$MODE" == "force-fail" ]]; then
  record_event "health-failed" "$VERSION"
  if [[ "$previous" != "none" ]]; then
    bash "$SCRIPT_DIR/rollback.sh" "$previous"
  fi
  exit 1
fi

record_known_good "$VERSION"
record_event "deploy-success" "$VERSION"
printf 'deployment succeeded: %s\n' "$VERSION"
