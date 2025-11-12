#!/usr/bin/env bash
# switch-to-private-if-streaming.sh — switches OBS to a private scene only when live-streaming.

set -euo pipefail

SCENE_NAME="Black (with mac sound)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECK_SCRIPT="$SCRIPT_DIR/check-obs-is-on.sh"
SWITCH_SCRIPT="$SCRIPT_DIR/switch-obs-scene.sh"

if [[ ! -x "$CHECK_SCRIPT" ]]; then
  echo "Missing or non-executable checker: $CHECK_SCRIPT" >&2
  exit 65
fi

if [[ ! -x "$SWITCH_SCRIPT" ]]; then
  echo "Missing or non-executable switcher: $SWITCH_SCRIPT" >&2
  exit 66
fi

set +e
status_output="$("$CHECK_SCRIPT")"
check_code=$?
set -e

status_output="${status_output//$'\r'/}"
status_output="${status_output//$'\n'/}"

case "$check_code" in
  0)
    printf 'OBS status: %s — switching to "%s".\n' "$status_output" "$SCENE_NAME"
    exec "$SWITCH_SCRIPT" "$SCENE_NAME"
    ;;
  *)
    printf 'OBS status: %s — no scene change.\n' "$status_output"
    exit "$check_code"
    ;;
esac
