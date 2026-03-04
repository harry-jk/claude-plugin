# Git Plugin

Claude Code에서 Git 저장소를 관리할 수 있게 해주는 플러그인입니다.

## 기능

### Git MCP 도구
- 저장소 관리 (init, clone, status, clean)
- 스테이징 & 커밋 (add, commit, diff)
- 히스토리 & 검사 (log, show, blame, reflog)
- 브랜칭 & 머징 (branch, checkout, merge, rebase, cherry-pick)
- 원격 작업 (remote, fetch, pull, push)
- 고급 워크플로우 (tag, stash, reset, worktree 등)

### Git Policy System

#### /policy-setup (command)
프로젝트별 Git 정책을 설정합니다:
- **Commit Confirmation**: 커밋 전 확인 필요 여부 설정
- **Commit Message Format**:
  - `none`: 티켓 없음 (예: `feat: add login`)
  - `no_ticket`: [NT] 플래그 포함 (예: `[NT] feat: add login`)
  - `branch`: 브랜치명에서 티켓 자동 추출 (예: `[PROJ-123] feat: add login`)
  - `custom`: 사용자 정의 티켓 (예: `[PROJ-123] feat: add login`)
- **Co-Authored-By Attribution**:
  - `no`: 생략
  - `yes_no_email`: 이메일 없이 (예: `Co-Authored-By: Claude Haiku 4.5`)
  - `yes_with_email`: 이메일 포함 (예: `Co-Authored-By: Claude Haiku 4.5 <noreply@anthropic.com>`)

#### git-policy-enforcement
설정된 정책을 Git 작업에 자동으로 적용합니다:
- 커밋 메시지 형식 검증
- 티켓 자동 전처리
- Co-Authored-By 자동 적용
- 정책 위반 시 가이드 제공

#### git-bash-prevention
Bash를 통한 직접 Git 명령어를 감지하고 Git MCP 도구 사용으로 유도합니다:
- Git 명령어 자동 감지 및 차단
- 쿼리 명령은 경고만 제공 (status, log, diff 등)
- 실행 명령은 MCP 도구로 유도 (commit, push, branch 등)
- 위험한 작업은 완전히 차단 (reset --hard, clean -f 등)

## 설치 전 준비

별도의 API 키나 환경 변수 설정이 필요 없습니다.

## 설치

```bash
/plugin install git@harry-claude-plugins
```

## 사용 예시

### 1. 정책 설정
프로젝트 시작 시 한 번만 설정합니다:

```
사용자: "/policy-setup"
→ policy-setup 커맨드 실행
→ 정책 선택 (커밋 확인, 메시지 형식, 서명 정보)
→ .claude/git-policy.json 생성
```

### 2. 정책 자동 적용
Git 작업할 때 정책이 자동으로 적용됩니다:

```
사용자: "변경사항을 커밋해"
→ git-policy-enforcement 스킬 실행
→ 메시지 형식 검증 및 수정
→ 속성 정보 자동 추가
→ 커밋 실행
```

### 3. Bash Git 명령 자동 리다이렉트
직접 Git 명령을 피하도록 유도합니다:

```
사용자: "$ git commit -m 'Fix bug'"
→ git-bash-prevention 스킬 감지
→ Git MCP 도구 사용 제안
→ 정책 적용된 안전한 커밋 실행
```
