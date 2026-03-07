---
description: 팀 리더 초기화, persona 로드, 작업 상태 관리. 사용자가 "팀 시작", "crew", "리더 시작", "작업 이어서", "팀 리드", "팀 작업", "take-helm" 등을 언급하거나, resume 후 이전 팀 작업을 이어가려 할 때 반드시 이 skill을 사용할 것.
allowed-tools: Read, Write, Bash, AskUserQuestion
---

### Step 0: 디렉토리 확인

`.claude/voyage/logs/` 디렉토리가 없으면 생성한다.

### Step 1: 기존 작업 확인

`.claude/voyage/logs/captain.md` 존재 여부를 확인한다.

**파일이 존재하면:**

1. captain.md 내용을 읽는다
2. 내용을 1줄로 요약하여 제시한다
3. AskUserQuestion으로 선택:

```yaml
Q: "이전 작업이 있습니다: {1줄 요약}. 어떻게 할까요?"
Header: "작업 선택"
Options:
  - "이어서 진행"
  - "새로 시작"
```

- **"이어서 진행"** 선택 시: captain.md 내용을 context에 로드
- **"새로 시작"** 선택 시: `.claude/voyage/logs/` 하위 파일 전체 삭제 (captain.md, captain-session, {session_id}.md 모두)

**파일이 존재하지 않으면:** 새 작업으로 시작.

### Step 2: captain-session 기록

`.claude/voyage/logs/captain-session` 파일에 현재 session_id를 기록한다.

session_id는 `${CLAUDE_SESSION_ID}` 변수로 가져온다.

### Step 3: Persona 로드

1. `${CLAUDE_PLUGIN_ROOT}/prompts/captain-persona.md` 읽기 (기본 persona)
2. `.claude/voyage/prompts/captain-persona.md` 존재 여부 확인
3. 존재하면 내용을 읽어 기본 persona 뒤에 append
4. 병합된 persona를 context에 로드

### Step 4: 작업 시작

- 사용자에게 작업 준비 완료를 알린다
- 팀원 spawn은 사용자 지시에 따라 별도 진행
- captain.md 초기 작성을 시작한다

### Step 5: 팀 생성 시 team-name 기록

TeamCreate로 팀을 생성한 직후, `.claude/voyage/logs/team-name` 파일에 팀 이름을 기록한다.

```bash
echo "팀이름" > .claude/voyage/logs/team-name
```

이 파일은 compact 후 팀 상태를 복구하는 데 사용된다. 팀 이름이 기록되지 않으면 compact 후 팀이 해체된 것으로 인식할 수 있다.

### captain.md 구조 가이드라인

```markdown
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
```
