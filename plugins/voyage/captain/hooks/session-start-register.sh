#!/bin/bash
# SessionStart(startup) hook: teammate 파일 등록
# 팀 활성 상태에서 captain이 아닌 세션이 시작되면 logs/{session_id}.md 생성

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')

[ -z "$SESSION_ID" ] && exit 0

LOGS_DIR="$CLAUDE_PROJECT_DIR/.claude/voyage/logs"

# voyage 디렉토리가 없으면 스킵 (voyage 미사용)
[ ! -d "$LOGS_DIR" ] && exit 0

# captain-session 파일이 없으면 스킵 (팀 비활성)
LEAD_FILE="$LOGS_DIR/captain-session"
[ ! -f "$LEAD_FILE" ] && exit 0

LEAD_SESSION=$(cat "$LEAD_FILE")

# captain 세션이면 스킵 (captain 등록은 take-helm skill이 처리)
[ "$SESSION_ID" = "$LEAD_SESSION" ] && exit 0

# 이미 파일이 있으면 스킵
[ -f "$LOGS_DIR/${SESSION_ID}.md" ] && exit 0

# teammate 상태 파일 초기 생성
cat > "$LOGS_DIR/${SESSION_ID}.md" << 'EOF'
# 작업 현황

## 목표
(작업 목표 1줄 요약)

## 현재 진행중
(지금 하고 있는 것)

## 완료된 항목
- (완료 항목들)

## 미결 사항
- (결정 필요한 것, 블로커)

## 다음 단계
(이후 할 것)
EOF

# teammate persona 주입
PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PERSONA_FILE="$PLUGIN_ROOT/prompts/crew-persona.md"

if [ -f "$PERSONA_FILE" ]; then
  CONTEXT=$(cat "$PERSONA_FILE")
  ESCAPED=$(echo "$CONTEXT" | jq -Rs .)
  echo "{\"hookSpecificOutput\":{\"hookEventName\":\"SessionStart\",\"additionalContext\":${ESCAPED}}}"
fi

exit 0
