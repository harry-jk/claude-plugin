#!/bin/bash
# SessionEnd hook: 리더 세션 종료 시 leader-session 삭제

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')

[ -z "$SESSION_ID" ] && exit 0

LEAD_FILE="$CLAUDE_PROJECT_DIR/.claude/crew/sessions/leader-session"

if [ -f "$LEAD_FILE" ]; then
  LEAD_SESSION=$(cat "$LEAD_FILE")
  if [ "$LEAD_SESSION" = "$SESSION_ID" ]; then
    rm -f "$LEAD_FILE"
    rm -f "$CLAUDE_PROJECT_DIR/.claude/crew/sessions/team-name"
  fi
fi

exit 0
