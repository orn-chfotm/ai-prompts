---
description: "codex dir init, claude dir init 요청 시 생성할 Agent adapter 기본 구조와 commit 기준을 정의합니다."
---

# Agent dir init

이 문서는 사용자가 채팅에서 Agent별 기본 디렉토리 생성을 요청했을 때 따라야 할 기준을 정의한다.

`docs`는 공통 하네스 문서만 가진다.

Agent별 실행 디렉토리는 사용자가 실제 프로젝트에서 필요할 때 생성한다.

## 기본 원칙

- `codex dir init`은 Codex 공식 구조에 맞는 로컬 adapter를 생성한다.
- `claude dir init`은 Claude 프로젝트 구조에 맞는 로컬 adapter를 생성한다.
- 파일은 내용 없는 빈 파일로 생성한다.
- 디렉토리는 비어 있는 디렉토리로 생성한다.
- 이미 존재하는 파일이 비어 있으면 유지한다.
- 이미 존재하는 파일에 내용이 있으면 덮어쓰기 전에 사용자 확인을 받는다.
- 생성된 adapter 구조는 프로젝트별 로컬 구조이며, 공통 하네스로 합의되지 않았다면 commit 대상으로 보지 않는다.

## codex dir init

사용자가 `codex dir init`을 요청하면 다음 구조를 생성한다.

```text
.codex/
  config.toml
  hooks.json
  rules/
  agents/
.agents/
  skills/
```

### 파일

- `.codex/config.toml`
- `.codex/hooks.json`

### 디렉토리

- `.codex/rules/`
- `.codex/agents/`
- `.agents/skills/`

### 금지

- `.codex/skills/`는 생성하지 않는다.
- Codex skill은 `.agents/skills/<skill-name>/SKILL.md`에 둔다.
- 공통 하네스 문서를 `.codex` 또는 `.agents`로 복사하지 않는다.

## claude dir init

사용자가 `claude dir init`을 요청하면 다음 구조를 생성한다.

```text
.claude/
  settings.json
  rules/
  skills/
  agents/
```

### 파일

- `.claude/settings.json`

### 디렉토리

- `.claude/rules/`
- `.claude/skills/`
- `.claude/agents/`

### 금지

- Codex 전용 `.agents/skills` 구조를 Claude skill 위치로 사용하지 않는다.
- Claude 전용 `@path` import 문법을 공통 `docs` 문서에 넣지 않는다.
- 공통 하네스 문서를 `.claude`로 복사하지 않는다.

## commit 기준

이 저장소를 submodule 또는 공통 하네스로 pull 받은 사용자는 필요한 Agent만 init한다.

기본적으로 init 결과물은 각 프로젝트의 로컬 adapter다.

다음 조건을 만족할 때만 init 결과물을 commit 대상으로 검토한다.

- 여러 프로젝트에서 동일하게 사용해야 하는 공통 adapter다.
- 개인 로컬 설정이 아니다.
- 실험용 설정이 아니다.
- 팀 또는 사용자 기준으로 공통 하네스의 일부로 합의되었다.

## 인식 기준

Codex가 이 규칙을 인식하려면 `AGENTS.md`에서 이 문서를 참조하거나 동일한 init 규칙을 직접 포함한다.

Claude가 이 규칙을 인식하려면 `CLAUDE.md` 상단에서 이 문서를 `@docs/00-docs/03-agent-dir-init.md`로 import한다.
