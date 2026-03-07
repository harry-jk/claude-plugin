---
description: crew 세션 데이터 정리. 작업 완료 후 sessions/ 하위 파일(leader.md, leader-session, teammate 파일)을 삭제한다. prompts/와 agents/는 유지.
disable-model-invocation: true
allowed-tools: Read, Glob, Bash, AskUserQuestion
---

### Step 1: 현재 상태 확인

`.claude/crew/sessions/` 디렉토리의 파일 목록을 Glob으로 확인하고 사용자에게 보여준다:
- leader.md 존재 여부
- leader-session 존재 여부
- teammate 파일 ({session_id}.md) 개수

### Step 2: 삭제 확인

AskUserQuestion으로 확인:

```yaml
Q: "crew 세션 데이터를 삭제합니다. 계속할까요?"
Header: "Crew 정리"
Options:
  - "삭제 진행"
  - "취소"
```

### Step 3: 삭제 실행

"삭제 진행" 선택 시:
- `.claude/crew/sessions/` 하위 파일 전체 삭제 (leader.md, leader-session, team-name, {session_id}.md)
- `.claude/crew/prompts/`는 유지
- `.claude/crew/agents/`는 유지
- 결과를 사용자에게 보고
