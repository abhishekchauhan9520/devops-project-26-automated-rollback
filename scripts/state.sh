#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="${STATE_DIR:-.release-state}"
GOOD_FILE="$STATE_DIR/known-good"
CURRENT_FILE="$STATE_DIR/current"
EVENT_LOG="$STATE_DIR/events.log"

init_state() { mkdir -p "$STATE_DIR"; }
record_known_good() { init_state; printf '%s\n' "$1" > "$GOOD_FILE"; }
record_current() { init_state; printf '%s\n' "$1" > "$CURRENT_FILE"; }
known_good() { [[ -s "$GOOD_FILE" ]] || return 1; cat "$GOOD_FILE"; }
current() { [[ -s "$CURRENT_FILE" ]] || return 1; cat "$CURRENT_FILE"; }
record_event() { init_state; printf '%s|%s|%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$1" "$2" >> "$EVENT_LOG"; }

case "${1:-}" in
  init) init_state ;;
  set-good) record_known_good "$2"; record_event "known-good" "$2" ;;
  set-current) record_current "$2"; record_event "current" "$2" ;;
  get-good) known_good ;;
  get-current) current ;;
  event) record_event "$2" "$3" ;;
  *) echo "usage: $0 {init|set-good|set-current|get-good|get-current|event}" >&2; exit 64 ;;
esac
