#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
STATE_DIR="${STATE_DIR:-$ROOT_DIR/.release-state}"

source "$SCRIPT_DIR/state.sh"

if [[ -z "$TARGET" ]]; then
  TARGET="$(known_good)" || { echo "no known-good release recorded" >&2; exit 2; }
fi

current="$(current 2>/dev/null || true)"
record_current "$TARGET"
record_known_good "$TARGET"
record_event "rollback" "${current:-unknown}->${TARGET}"
printf 'rollback completed: %s -> %s\n' "${current:-unknown}" "$TARGET"
