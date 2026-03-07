#!/bin/bash
# SessionStart(compact) hook: context 복구
# captain → persona + captain.md 주입
# teammate → persona + 자기 logs/{session_id}.md 주입

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
VOYAGE_DIR="$CLAUDE_PROJECT_DIR/.claude/voyage"
LOGS_DIR="$VOYAGE_DIR/logs"

# voyage 디렉토리가 없으면 스킵
if [ ! -d "$LOGS_DIR" ]; then
  exit 0
fi

# captain-session 파일이 없으면 스킵
LEAD_FILE="$LOGS_DIR/captain-session"
if [ ! -f "$LEAD_FILE" ]; then
  exit 0
fi

LEAD_SESSION=$(cat "$LEAD_FILE")
CONTEXT=""

if [ "$SESSION_ID" = "$LEAD_SESSION" ]; then
  # captain: persona + captain.md 주입
  PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  PERSONA_BASE="$PLUGIN_ROOT/prompts/captain-persona.md"
  PERSONA_PROJECT="$VOYAGE_DIR/prompts/captain-persona.md"
  STATUS_FILE="$LOGS_DIR/captain.md"

  if [ -f "$PERSONA_BASE" ]; then
    CONTEXT=$(cat "$PERSONA_BASE")
  fi

  if [ -f "$PERSONA_PROJECT" ]; then
    CONTEXT="${CONTEXT}

$(cat "$PERSONA_PROJECT")"
  fi

  if [ -f "$STATUS_FILE" ]; then
    CONTEXT="${CONTEXT}

---
# 현재 작업 상태 (compact 복구)
$(cat "$STATUS_FILE")"
  fi

  # 팀 정보 복구
  TEAM_NAME_FILE="$LOGS_DIR/team-name"
  if [ -f "$TEAM_NAME_FILE" ]; then
    TEAM_NAME=$(cat "$TEAM_NAME_FILE")
    TEAM_CONFIG="$HOME/.claude/teams/${TEAM_NAME}/config.json"
    if [ -f "$TEAM_CONFIG" ]; then
      CONTEXT="${CONTEXT}

---
# 활성 팀 정보 (compact 복구)
팀 이름: ${TEAM_NAME}
팀이 활성 상태입니다. 해체하지 마세요.

## 팀 구성원
$(cat "$TEAM_CONFIG" | jq -r '.members[] | "- \(.name) (\(.agentType // "general"))"' 2>/dev/null || echo "(config 파싱 실패)")"
    fi
  fi
else
  # teammate: persona + 자기 파일 주입
  PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  PERSONA_FILE="$PLUGIN_ROOT/prompts/crew-persona.md"

  if [ -f "$PERSONA_FILE" ]; then
    CONTEXT=$(cat "$PERSONA_FILE")
  fi

  STATUS_FILE="$LOGS_DIR/${SESSION_ID}.md"

  if [ -f "$STATUS_FILE" ]; then
    CONTEXT="${CONTEXT}

---
# 현재 작업 상태 (compact 복구)
$(cat "$STATUS_FILE")"
  fi
fi

# context가 있으면 additionalContext로 주입
if [ -n "$CONTEXT" ]; then
  ESCAPED=$(echo "$CONTEXT" | jq -Rs .)
  echo "{\"hookSpecificOutput\":{\"hookEventName\":\"SessionStart\",\"additionalContext\":${ESCAPED}}}"
  exit 0
fi

exit 0
