#!/bin/bash
# allow-policy-write.sh
# policy-setup command 실행 중 .claude/git-policy.json Write를 자동 승인

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')

if echo "$FILE_PATH" | grep -qE "(^|/)\.claude/git-policy\.json$"; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "allow",
      permissionDecisionReason: "policy-setup: auto-approved write to .claude/git-policy.json"
    }
  }'
fi

exit 0
