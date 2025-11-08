#!/bin/bash

set -euo pipefail

# Grab the frontmost Safari tab URL via AppleScript
if ! safari_url="$(osascript -e 'tell application "Safari" to return URL of front document' 2>/dev/null | tr -d '\r\n')"; then
  echo "Failed to retrieve Safari front document URL." >&2
  exit 1
fi

if [[ -z "$safari_url" ]]; then
  echo "Safari did not provide a front document URL." >&2
  exit 1
fi

echo "Opening $safari_url with fe privateForkRepoAndOpen..."
fe privateForkRepoAndOpen "$safari_url"
