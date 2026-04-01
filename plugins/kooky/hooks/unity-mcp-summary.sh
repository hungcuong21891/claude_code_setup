#!/bin/bash
# Hook: Show Unity MCP session summary on Stop.
# Event: Stop
#
# If Unity MCP was used, blocks once to display the summary.

INPUT=$(cat)

# Prevent infinite loop
STOP_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active')
if [ "$STOP_ACTIVE" = "true" ]; then
  exit 0
fi

LOG_FILE="${TMPDIR:-/tmp}/unity-mcp-session.log"

# No MCP calls this session, allow stopping
if [ ! -f "$LOG_FILE" ]; then
  exit 0
fi

LINES=$(wc -l < "$LOG_FILE" | tr -d ' ')
CONTENT=$(cat "$LOG_FILE")
rm -f "$LOG_FILE"

jq -n --arg reason "Before ending, please summarize the Unity MCP actions from this session in your own words. Here is the raw log ($LINES calls):
$CONTENT" '{
  "decision": "block",
  "reason": $reason
}'

exit 0
