#!/bin/bash
# Stop hook: 상태 파일 갱신 강제
# 리더 → sessions/leader.md / teammate → sessions/{session_id}.md
# 10초 이내 수정되지 않았으면 block

CREW_DIR="$CLAUDE_PROJECT_DIR/.claude/crew/sessions"

# crew 디렉토리가 없으면 스킵 (crew 미사용 프로젝트)
[ ! -d "$CREW_DIR" ] && exit 0

# leader-session 파일이 없으면 스킵 (팀 비활성)
LEAD_FILE="$CREW_DIR/leader-session"
[ ! -f "$LEAD_FILE" ] && exit 0

INPUT=$(cat)
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')

# 이미 stop hook에 의해 재실행 중이면 무한루프 방지
if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
  exit 0
fi

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
LEAD_SESSION=$(cat "$LEAD_FILE")

# 대상 파일 결정
if [ "$SESSION_ID" = "$LEAD_SESSION" ]; then
  STATUS_FILE="$CREW_DIR/leader.md"
  FILE_LABEL="sessions/leader.md"
elif [ -f "$CREW_DIR/${SESSION_ID}.md" ]; then
  STATUS_FILE="$CREW_DIR/${SESSION_ID}.md"
  FILE_LABEL="sessions/${SESSION_ID}.md"
else
  # 리더도 아니고 teammate 파일도 없음 → crew 무관 세션, 스킵
  exit 0
fi

# 파일이 없으면 block (리더인데 leader.md 미생성)
if [ ! -f "$STATUS_FILE" ]; then
  jq -n --arg reason ".claude/crew/${FILE_LABEL} 파일이 없습니다. 현재 작업 내용, 진행 상황, 다음 단계를 기록하세요." \
    '{"decision":"block","reason":$reason}'
  exit 0
fi

# 10초 freshness 체크 (크로스 플랫폼 stat)
if stat -f %m "$STATUS_FILE" >/dev/null 2>&1; then
  FILE_MTIME=$(stat -f %m "$STATUS_FILE")
else
  FILE_MTIME=$(stat -c %Y "$STATUS_FILE")
fi
FILE_AGE_SEC=$(( $(date +%s) - FILE_MTIME ))

if [ "$FILE_AGE_SEC" -gt 10 ]; then
  jq -n --arg reason ".claude/crew/${FILE_LABEL}가 ${FILE_AGE_SEC}초 전 수정됨 (10초 이내 필요). 현재 작업 내용, 진행 상황, 다음 단계를 지금 즉시 업데이트하세요." \
    '{"decision":"block","reason":$reason}'
  exit 0
fi

exit 0
