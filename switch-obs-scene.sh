#!/usr/bin/env bash
# switch-obs-scene.sh — macOS helper that makes OBS jump to a given scene via UI scripting.
# Usage: ./sh/switch-obs-scene.sh ["Scene Name"]
# Defaults to "Black (with mac sound)" when no scene is provided.

set -euo pipefail

SCENE_NAME="${1:-Black (with mac sound)}"

run_applescript() {
  osascript <<'APPLESCRIPT' "$SCENE_NAME"
on run argv
  set sceneName to item 1 of argv
  tell application "System Events"
    if not (exists process "OBS") then return "OBS_NOT_RUNNING"
    tell process "OBS"
      set frontmost to true
      set obsWindow to my firstStandardWindow(windows)
      if obsWindow is missing value then return "OBS_WINDOW_NOT_FOUND"
      set sceneRow to my locateSceneRow(sceneName, obsWindow)
      if sceneRow is missing value then return "SCENE_NOT_FOUND"
      try
        perform action "AXPress" of sceneRow
        return "OK"
      on error errMsg number errNum
        return "FAILED:" & errMsg
      end try
    end tell
  end tell
end run

on firstStandardWindow(obsWindows)
  repeat with w in obsWindows
    try
      if subrole of w is "AXStandardWindow" then return w
    end try
  end repeat
  return missing value
end firstStandardWindow

on locateSceneRow(sceneName, container)
  repeat with elem in entire contents of container
    try
      if name of elem is sceneName then
        set rowCandidate to my ascendToSelectable(elem)
        if rowCandidate is not missing value then return rowCandidate
      end if
    end try
  end repeat
  return missing value
end locateSceneRow

on ascendToSelectable(elem)
  repeat 6 times
    try
      set currentRole to role of elem
      if currentRole is "AXRow" or currentRole is "AXListItem" then return elem
      set elem to parent of elem
    on error
      exit repeat
    end try
  end repeat
  return missing value
end ascendToSelectable
APPLESCRIPT
}

if ! status="$(run_applescript)"; then
  echo "Failed to communicate with AppleScript/OBS." >&2
  exit 64
fi

# Clean up trailing CR/LF that osascript may add.
status="${status//$'\r'/}"
status="${status//$'\n'/}"

case "$status" in
  OK)
    printf 'Switched OBS to scene "%s".\n' "$SCENE_NAME"
    exit 0
    ;;
  OBS_NOT_RUNNING)
    echo "OBS is not running; launch it first." >&2
    exit 2
    ;;
  OBS_WINDOW_NOT_FOUND)
    echo "Could not find the main OBS window. Ensure OBS has an open scene collection." >&2
    exit 3
    ;;
  SCENE_NOT_FOUND)
    printf 'Scene "%s" was not found in OBS.\n' "$SCENE_NAME" >&2
    exit 4
    ;;
  FAILED:*)
    echo "OBS returned an unexpected UI error: ${status#FAILED:}" >&2
    exit 5
    ;;
  *)
    echo "Unexpected response from AppleScript: $status" >&2
    exit 6
    ;;
esac
