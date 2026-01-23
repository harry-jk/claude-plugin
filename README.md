# Harry's Claude Plugin Marketplace

개인용 Claude Code 플러그인 마켓플레이스입니다.

## 사용법

### 마켓플레이스 등록

```bash
# GitHub에 push 후
/plugin marketplace add harry/claude-plugin

# 또는 로컬에서 테스트
/plugin marketplace add /path/to/claude-plugin
```

### 플러그인 설치

```bash
/plugin install <plugin-name>@harry-claude-plugins
```

## 프로젝트 구조

```
claude-plugin/
├── .claude-plugin/
│   └── marketplace.json      # 마켓플레이스 메타데이터
├── plugins/
│   ├── _template/            # 플러그인 템플릿
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json   # 플러그인 메타데이터
│   │   ├── commands/         # 슬래시 명령어
│   │   ├── skills/           # Agent Skills
│   │   ├── agents/           # 커스텀 서브에이전트
│   │   ├── hooks/            # 이벤트 훅
│   │   └── scripts/          # 스크립트 파일
│   └── <your-plugin>/        # 실제 플러그인들
└── README.md
```

## 새 플러그인 추가하기

1. `plugins/_template`을 복사하여 새 플러그인 디렉토리 생성
2. `.claude-plugin/plugin.json` 수정
3. 필요한 컴포넌트 작성 (commands, skills, agents, hooks)
4. `.claude-plugin/marketplace.json`의 plugins 배열에 추가

### marketplace.json에 플러그인 등록 예시

```json
{
  "plugins": [
    {
      "name": "my-plugin",
      "source": "./plugins/my-plugin",
      "description": "플러그인 설명",
      "version": "1.0.0",
      "keywords": ["keyword1", "keyword2"],
      "category": "development"
    }
  ]
}
```

## 플러그인 컴포넌트

| 컴포넌트 | 위치 | 설명 |
|---------|------|------|
| Commands | `commands/*.md` | `/명령어`로 실행되는 간단한 명령 |
| Skills | `skills/*/SKILL.md` | Claude가 자동으로 호출할 수 있는 기능 |
| Agents | `agents/*.md` | Task 도구로 호출되는 서브에이전트 |
| Hooks | `hooks/hooks.json` | 도구 실행 전후에 트리거되는 스크립트 |
| MCP | `.mcp.json` | MCP 서버 설정 |
| LSP | `.lsp.json` | LSP 서버 설정 |

## 로컬 테스트

```bash
# 특정 플러그인 테스트
claude --plugin-dir ./plugins/my-plugin

# 여러 플러그인 동시 테스트
claude --plugin-dir ./plugins/plugin1 --plugin-dir ./plugins/plugin2
```
