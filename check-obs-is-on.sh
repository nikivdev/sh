#!/usr/bin/env bash
# check-obs-is-on.sh — quick helper that reports whether OBS is currently streaming.
# Prints one of: STREAMING | NOT_STREAMING | OBS_NOT_RUNNING | UNKNOWN
# Exits with: 0 streaming, 1 not streaming, 2 OBS not running, 3 unknown/error

set -euo pipefail

run_query() {
  /usr/bin/osascript <<'APPLESCRIPT'
tell application "System Events"
	if not (exists process "OBS") then return "OBS_NOT_RUNNING"
	tell process "OBS"
		repeat with w in windows
			try
				set streamingButtons to (buttons of w whose name is "Stop Streaming")
				if streamingButtons is not {} then return "STREAMING"
			end try
		end repeat
		return "NOT_STREAMING"
	end tell
end tell
APPLESCRIPT
}

set +e
status="$(run_query)"
osa_exit=$?
set -e

if (( osa_exit != 0 )); then
  echo "Failed to query OBS streaming status (osascript exit $osa_exit). Check Accessibility + Automation permissions for your shell." >&2
  echo "UNKNOWN"
  exit 3
fi

case "$status" in
  STREAMING)
    echo "$status"
    exit 0
    ;;
  NOT_STREAMING)
    echo "$status"
    exit 1
    ;;
  OBS_NOT_RUNNING)
    echo "$status"
    exit 2
    ;;
  *)
    echo "UNKNOWN" >&2
    echo "UNKNOWN"
    exit 3
    ;;
esac
