#!/bin/bash
# Hook: Show Unity MCP session summary on Stop.
# Event: Stop
#
# Blocks stopping once to display the session log, then allows on retry.

INPUT=$(cat)

# Prevent infinite loop: if we already blocked once, allow stopping
STOP_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active')
if [ "$STOP_ACTIVE" = "true" ]; then
  exit 0
fi

LOG_FILE="${TMPDIR:-/tmp}/unity-mcp-session.log"

# No MCP calls happened, allow stopping
if [ ! -f "$LOG_FILE" ]; then
  exit 0
fi

LINES=$(wc -l < "$LOG_FILE" | tr -d ' ')
CONTENT=$(cat "$LOG_FILE")

# Clean up the log file
rm -f "$LOG_FILE"

# Block stopping to show the summary
jq -n --arg reason "Unity MCP Session Summary ($LINES calls):
$CONTENT" '{
  "hookSpecificOutput": {
    "hookEventName": "Stop",
    "decision": "block",
    "reason": $reason
  }
}'

exit 0
