#!/bin/bash
# Hook: Inject Unity MCP tool usage summary into the agent's response.
# Event: PostToolUse / PostToolUseFailure (matcher: mcp__UnityMCP__.*)
#
# Outputs JSON with additionalContext so the agent includes a step summary.

INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "unknown"')
TOOL_INPUT=$(echo "$INPUT" | jq -c '.tool_input // {}')

# Extract the short tool name (strip mcp__UnityMCP__ prefix)
SHORT_NAME=$(echo "$TOOL_NAME" | sed 's/^mcp__UnityMCP__//')

# Extract action if present (most Unity MCP tools use an "action" param)
ACTION=$(echo "$INPUT" | jq -r '.tool_input.action // empty')

# Build a readable description
if [ -n "$ACTION" ]; then
  DESCRIPTION="${SHORT_NAME} -> ${ACTION}"
else
  DESCRIPTION="${SHORT_NAME}"
fi

# Extract key parameters (skip verbose fields like action, large content)
PARAMS=$(echo "$TOOL_INPUT" | jq -c 'del(.action, .content, .code, .script_content) | to_entries | map(select(.value != null and .value != "")) | from_entries')

# Check success/failure
ERROR=$(echo "$INPUT" | jq -r '.error // empty')
if [ -n "$ERROR" ]; then
  STATUS="FAILED: ${ERROR}"
else
  STATUS="OK"
fi

# Build the summary line
SUMMARY="[Unity MCP Step] ${DESCRIPTION} | params: ${PARAMS} | ${STATUS}"

# Output additionalContext to inject into agent's response
jq -n --arg ctx "$SUMMARY" '{
  "hookSpecificOutput": {
    "additionalContext": $ctx
  }
}'

exit 0
