#!/usr/bin/env bash
# check-obs-is-on.sh — macOS helper that reports OBS streaming status via UI scripting.
# Prints one of: STREAMING | RECORDING_ONLY | IDLE | OBS_NOT_RUNNING | UNKNOWN
# Exits with: 0 streaming, 10 recording-only, 1 idle, 2 not running, 3 unknown

set -euo pipefail

status="$(osascript <<'APPLESCRIPT'
tell application "System Events"
  if not (exists process "OBS") then return "OBS_NOT_RUNNING"
  tell process "OBS"
    try
      set obsWindow to missing value
      set windowList to windows
      repeat with w in windowList
        try
          if subrole of w is "AXStandardWindow" then
            set obsWindow to w
            exit repeat
          end if
        end try
      end repeat
      if obsWindow is missing value then
        if windowList is {} then error "OBS window not found"
        set obsWindow to first item of windowList
      end if

      set btnNames to {}
      set deepContents to entire contents of obsWindow
      repeat with elem in deepContents
        try
          if role of elem is "AXButton" then
            set end of btnNames to (name of elem as text)
          end if
        end try
      end repeat

      set isStreaming to my containsValue(btnNames, "Stop Streaming")
      set isRecording to my containsValue(btnNames, "Stop Recording")
      if isStreaming then
        return "STREAMING"
      else if isRecording then
        return "RECORDING_ONLY"
      else
        return "IDLE"
      end if
    on error errMsg number errNum
      return "ERROR|" & errNum & "|" & errMsg
    end try
  end tell
end tell

on containsValue(textList, targetValue)
  repeat with itemText in textList
    if itemText is targetValue then return true
  end repeat
  return false
end containsValue
APPLESCRIPT
)"

if [[ "$status" == ERROR\|* ]]; then
  err_detail="${status#ERROR|}"
  echo "Failed to query OBS UI status (grant accessibility and automation permissions to your terminal?): $err_detail" >&2
  status="UNKNOWN"
fi

echo "$status"

case "$status" in
  STREAMING) exit 0 ;;
  RECORDING_ONLY) exit 10 ;;
  IDLE) exit 1 ;;
  OBS_NOT_RUNNING) exit 2 ;;
  UNKNOWN) exit 3 ;;
  *) echo "Unexpected status string: $status" >&2; exit 3 ;;
esac
