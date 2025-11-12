#!/usr/bin/env bash
# check-obs-streaming.sh  — returns 0 if streaming, 1 otherwise

# Quick ping request to OBS WebSocket (no heavy JSON parsing)
json='{"op":6,"d":{"requestType":"GetStreamStatus","requestId":"1"}}'

# Send the query and capture single response line
resp="$(printf '%s\n' "$json" \
  | nc -w 1 127.0.0.1 4455 2>/dev/null \
  | grep -m1 '"requestType":"GetStreamStatus"')"

# Instant decision
if echo "$resp" | grep -q '"outputActive":true'; then
  echo "yes"
  exit 0
else
  echo "no"
  exit 1
fi
