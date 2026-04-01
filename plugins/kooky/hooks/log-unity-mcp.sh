#!/bin/bash
# Hook: Log Unity MCP tool calls to a temp file for session summary.
# Event: PostToolUse / PostToolUseFailure (matcher: mcp__UnityMCP__.*)

INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "unknown"')
SHORT_NAME=$(echo "$TOOL_NAME" | sed 's/^mcp__UnityMCP__//')
ACTION=$(echo "$INPUT" | jq -r '.tool_input.action // empty')
PARAMS=$(echo "$INPUT" | jq -c '.tool_input // {} | del(.action, .content, .code, .script_content) | to_entries | map(select(.value != null and .value != "")) | from_entries')

if [ -n "$ACTION" ]; then
  DESCRIPTION="${SHORT_NAME} -> ${ACTION}"
else
  DESCRIPTION="${SHORT_NAME}"
fi

ERROR=$(echo "$INPUT" | jq -r '.error // empty')
if [ -n "$ERROR" ]; then
  STATUS="FAILED: ${ERROR}"
else
  STATUS="OK"
fi

LOG_FILE="${TMPDIR:-/tmp}/unity-mcp-session.log"
echo "$(date '+%H:%M:%S') ${DESCRIPTION} | params: ${PARAMS} | ${STATUS}" >> "$LOG_FILE"

exit 0
