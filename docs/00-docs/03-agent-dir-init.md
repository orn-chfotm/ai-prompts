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
- 무조건 프로젝트 루트가 아닌 프롬프트의 루트 디렉토리 하위에 생성한다.

## 생성 위치 기준

`.claude/`, `.codex/`, `.agents/` adapter 디렉토리는 **항상 프로젝트 루트**에 생성한다.

Claude Code와 Codex는 각각 프로젝트 루트의 `.claude/`, `.codex/`만 설정 디렉토리로 인식한다. 하네스가 submodule로 하위 폴더에 있더라도 adapter 디렉토리는 submodule 내부가 아니라 프로젝트 루트에 위치해야 한다.

### 케이스 1: 이 하네스가 프로젝트 내 별도 하위 폴더(submodule)로 사용되는 경우

```text
my-project/               ← 프로젝트 루트 (여기가 기준)
  any-harness-name/       ← 이 하네스 submodule (이름 무관)
    docs/
    CLAUDE.md
    AGENTS.md
  .claude/                ← 여기에 생성  ✅
  .codex/                 ← 여기에 생성  ✅
  .agents/                ← 여기에 생성  ✅
  CLAUDE.md               ← 여기에 생성 (harness 연결용)  ✅
  AGENTS.md               ← 여기에 생성 (harness 연결용)  ✅
  src/
```

### 케이스 2: 이 하네스가 프로젝트 루트에 직접 위치하는 경우

```text
my-project/               ← 프로젝트 루트 = 하네스 루트
  docs/
  CLAUDE.md               ← 하네스 CLAUDE.md가 곧 루트 CLAUDE.md
  AGENTS.md
  .claude/                ← 여기에 생성  ✅
  .codex/                 ← 여기에 생성  ✅
  .agents/                ← 여기에 생성  ✅
  src/
```

케이스 2는 이미 `CLAUDE.md`와 `AGENTS.md`가 루트에 존재하므로 별도 생성하지 않는다.

### 판단 기준 요약

| 상황 | adapter 생성 위치 | Agent 인식용 md |
|---|---|---|
| 하네스가 submodule (하위 폴더) | 프로젝트 루트 | 프로젝트 루트에 별도 생성 |
| 하네스가 프로젝트 루트에 직접 존재 | 프로젝트 루트 | 하네스 md가 루트 md이므로 생략 |

## Agent 인식용 md 파일 생성

하네스가 submodule로 사용되는 경우(케이스 1), init 시 각 Agent가 하네스 docs를 인식할 수 있도록 프로젝트 루트에 md 파일을 함께 생성한다.

### claude dir init 시 — CLAUDE.md 생성

프로젝트 루트에 `CLAUDE.md`를 생성하고, 하네스 submodule의 `CLAUDE.md`를 import한다.

```md
@<submodule-path>/CLAUDE.md
```

- `<submodule-path>`는 실제 하네스 submodule 경로로 대체한다. (예: `ai-prompts`)
- 이미 `CLAUDE.md`가 존재하고 내용이 있으면 덮어쓰기 전에 사용자 확인을 받는다.
- 이 import를 통해 Claude는 `docs/` 하위 모든 하네스 규칙을 인식한다.

### codex dir init 시 — AGENTS.md 생성

프로젝트 루트에 `AGENTS.md`를 생성하고, 하네스 docs 파일 목록을 참조 안내로 포함한다.

```md
---
description: "이 프로젝트의 Codex 진입점입니다. 공통 협업 규칙은 아래 docs 문서를 기준으로 참조합니다."
---

# AGENTS.md

## 참조 문서

- <submodule-path>/docs/00-docs/01-md-structure.md
- <submodule-path>/docs/20-ai-process/agents/02-role-model.md
- <submodule-path>/docs/20-ai-process/agents/03-approval-authority.md
- <submodule-path>/docs/30-execution/01-workflow.md
- <submodule-path>/docs/40-plan/01-plan-structure.md
- <submodule-path>/docs/50-review/01-review-process.md
```

- `<submodule-path>`는 실제 하네스 submodule 경로로 대체한다.
- 이미 `AGENTS.md`가 존재하고 내용이 있으면 덮어쓰기 전에 사용자 확인을 받는다.

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

## 예약 명령 (PM 계획 생략 가능)

다음 명령은 하네스에서 미리 정의한 절차이므로 PM/CTO/PL 계획 없이 바로 실행한다.

| 명령 | 동작 |
|---|---|
| `claude dir init` | `.claude/` 로컬 adapter 구조 생성 |
| `codex dir init` | `.codex/`, `.agents/` 로컬 adapter 구조 생성 |
