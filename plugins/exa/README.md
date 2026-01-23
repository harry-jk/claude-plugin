# Exa Plugin

Claude Code에서 Exa AI 검색 기능을 사용할 수 있게 해주는 플러그인입니다.

## 기능

- `web_search_exa`: 실시간 웹 검색
- `get_code_context_exa`: 코드 검색
- `company_research`: 회사 정보 조사
- `crawling`: URL 콘텐츠 추출
- `linkedin_search`: LinkedIn 검색

## 설치 전 준비

1. [Exa Dashboard](https://dashboard.exa.ai/api-keys)에서 API 키 발급
2. 환경 변수 설정

## 환경 변수 설정 방법

### 방법 1: 쉘 환경 변수

```bash
export EXA_API_KEY="your-api-key-here"
```

### 방법 2: Claude settings.json

`~/.claude/settings.json`:

```json
{
  "env": {
    "EXA_API_KEY": "your-api-key-here"
  }
}
```

## 설치

```bash
/plugin install exa@harry-claude-plugins
```
