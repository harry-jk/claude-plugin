---
description: voyage 세션 데이터 정리. 작업 완료 후 logs/ 하위 파일(captain.md, captain-session, teammate 파일)을 삭제한다. prompts/와 crew/는 유지.
disable-model-invocation: true
allowed-tools: Read, Glob, Bash, AskUserQuestion
---

### Step 1: 현재 상태 확인

`.claude/voyage/logs/` 디렉토리의 파일 목록을 Glob으로 확인하고 사용자에게 보여준다:
- captain.md 존재 여부
- captain-session 존재 여부
- teammate 파일 ({session_id}.md) 개수

### Step 2: 활성 팀 경고

`captain-session` 파일이 존재하면 팀이 아직 활성 상태임을 의미한다. AskUserQuestion으로 경고:

```yaml
Q: "captain-session이 활성 상태입니다. 팀이 아직 운영 중일 수 있습니다. 강제로 정리할까요?"
Header: "활성 팀 경고"
Options:
  - "강제 정리"
  - "취소"
```

"취소" 선택 시 종료. `captain-session`이 없으면 이 단계를 건너뛴다.

### Step 3: 삭제 확인

AskUserQuestion으로 확인:

```yaml
Q: "voyage 세션 데이터를 삭제합니다. 계속할까요?"
Header: "Voyage 정리"
Options:
  - "삭제 진행"
  - "취소"
```

### Step 4: 삭제 실행

"삭제 진행" 선택 시:
- `.claude/voyage/logs/` 하위 파일 전체 삭제 (captain.md, captain-session, team-name, {session_id}.md)
- `.claude/voyage/prompts/`는 유지
- `.claude/voyage/crew/`는 유지
- 결과를 사용자에게 보고
