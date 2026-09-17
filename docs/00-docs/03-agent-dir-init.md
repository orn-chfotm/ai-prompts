---
description: "dir init, codex dir init, claude dir init 요청 시 생성할 Agent adapter 기본 구조와 commit 기준을 정의합니다."
---

# Agent dir init

이 문서는 사용자가 채팅에서 tool별 기본 adapter 디렉토리 생성을 요청했을 때 따라야 할 기준을 정의한다.

`docs`는 공통 하네스 문서만 가진다.

tool별 실행 디렉토리는 사용자가 실제 프로젝트에서 필요할 때 생성한다.

## 실행 툴별 진입점

AI tool은 프로젝트 지침 파일명과 import 문법이 서로 다를 수 있다.

따라서 모든 AI 툴을 아우르는 공통 상위 md를 별도로 만들지 않고, 실행 툴별 진입점을 분리한다.

| 실행 툴 | 프로젝트 루트 진입점 | 공통 하네스 진입점 |
|---|---|---|
| Claude | `CLAUDE.md` | `ai-prompts/CLAUDE.md` |
| Codex | `AGENTS.md` | `ai-prompts/AGENTS.md` |

Claude 프로젝트에서는 루트 `CLAUDE.md`가 `ai-prompts/CLAUDE.md`를 import한다.
Codex 프로젝트에서는 루트 `AGENTS.md`가 `ai-prompts/AGENTS.md`의 참조 안내 구조를 따른다.

Codex의 `AGENTS.md`는 Claude의 `@path` import처럼 참조 문서 본문을 자동으로 확장하는 구조가 아니다.

따라서 Codex용 참조 문서 목록은 자동 로드가 아니라, Codex가 작업 중 필요할 때 읽어야 하는 하네스 문서 안내로 사용한다.

## 기본 원칙

- `dir init`은 현재 실행 중인 AI 환경이 Claude인지 Codex인지 판단해 해당 adapter init을 실행한다.
- 현재 자동 init을 지원하는 AI 환경은 Claude와 Codex로 제한한다.
- 지원하지 않는 AI 환경에서 `dir init`을 요청하면 바로 구조를 생성하지 않고, 아래 "미지원 AI 처리" 기준을 따른다.
- `codex dir init`은 Codex가 공식적으로 인식하는 위치를 포함한 starter adapter를 생성한다.
- `claude dir init`은 Claude 프로젝트 구조에 맞는 로컬 adapter를 생성한다.
- 파일은 내용 없는 빈 파일로 생성한다. 이 기본 동작은 바꾸지 않는다.
- 디렉토리는 비어 있는 디렉토리로 생성한다.
- 빈 파일 대신 하네스가 배포하는 adapter 템플릿을 설치하려면 `--from-template` 옵션을 사용한다. 기준은 아래 "--from-template 옵션"을 따른다.
- 이미 존재하는 파일이 비어 있으면 유지한다.
- 이미 존재하는 파일에 내용이 있으면 덮어쓰기 전에 사용자 확인을 받는다.
- 생성된 adapter 구조는 프로젝트별 로컬 구조이며, 공통 하네스로 합의되지 않았다면 commit 대상으로 보지 않는다.
- adapter 디렉토리는 하네스 submodule 내부가 아니라 인식된 프로젝트 루트에 생성한다.
- `--path` 옵션으로 루트로 인식할 위치를 지정할 수 있다. 기준은 아래 "--path 옵션"을 따른다.

## --path 옵션

`dir init`, `codex dir init`, `claude dir init`은 `--path` 옵션으로 루트 인식 위치를 지정할 수 있다.

| 명령 형태 | 루트 인식 기준 |
|---|---|
| `dir init` | 현재 실행 AI 환경이 Claude이면 `claude dir init`, Codex이면 `codex dir init`으로 처리한다 |
| `claude dir init` / `codex dir init` | 옵션이 없으면 기존과 동일하게 "생성 위치 기준"에 따라 프로젝트 루트를 판단한다 |
| `dir init --path` | 현재 실행 AI 환경에 맞는 init을 실행하고, `--path` 뒤에 경로가 없으면 명령을 실행한 현재 위치를 프로젝트 루트로 인식한다 |
| `claude dir init --path` / `codex dir init --path` | `--path` 뒤에 경로가 없으면 명령을 실행한 현재 위치를 프로젝트 루트로 인식한다 |
| `dir init --path <경로>` | 현재 실행 AI 환경에 맞는 init을 실행하고, 지정한 경로를 프로젝트 루트로 인식한다 |
| `claude dir init --path <경로>` / `codex dir init --path <경로>` | 지정한 경로를 프로젝트 루트로 인식한다 |

경로 해석 기준:

- 상대 경로는 명령을 실행한 현재 위치를 기준으로 해석한다.
- 절대 경로는 그대로 사용한다.
- 지정한 경로가 존재하지 않으면 생성 전에 사용자 확인을 받는다.
- 하네스가 submodule로 사용되는 프로젝트에서 하네스 submodule 내부 경로를 루트로 지정하지 않는다.

루트 인식 후 처리 기준:

- 인식된 루트를 프로젝트 루트로 보고, "생성 위치 기준"의 케이스 1/케이스 2 판단과 예약 파일 생성 규칙을 동일하게 적용한다.
- adapter 디렉토리(`.claude/`, `.codex/`, `.agents/`)와 Agent 인식용 md(`CLAUDE.md`, `AGENTS.md`)는 인식된 루트에 생성한다.
- Agent 인식용 md의 `<submodule-path>`는 인식된 루트에서 하네스까지의 상대 경로로 계산한다.
- 이미 존재하는 파일 처리, commit 기준은 옵션 없는 init과 동일하다.

## --from-template 옵션

`dir init --from-template` 또는 `claude dir init --from-template`은 빈 파일 대신 하네스 저장소의 `adapters/claude/` 템플릿을 프로젝트 로컬 `.claude/`로 복사한다.

옵션을 붙이지 않은 `dir init`의 동작은 기존과 동일하다. 즉 **빈 파일 생성이 여전히 기본 동작이고**, 템플릿 복사는 사용자가 명시적으로 요청했을 때만 수행한다.

### 복사 매핑

| 하네스 템플릿 | 프로젝트 설치 위치 |
|---|---|
| `adapters/claude/agents/*.md` | `.claude/agents/` |
| `adapters/claude/hooks/*.sh` | `.claude/hooks/` |
| `adapters/claude/rules/01-workflow-gate.md` | `.claude/rules/process/01-workflow-gate.md` |
| `adapters/claude/skills/ai-process-workflow/` | `.claude/skills/ai-process-workflow/` |
| `adapters/claude/settings.hooks.json` | `.claude/settings.json`의 `hooks` 키에 **병합** |

### settings.hooks.json 처리

`settings.hooks.json`은 `.claude/settings.json`을 통째로 덮어쓰지 않는다.

- 기존 `.claude/settings.json`을 읽고, 그 JSON의 `hooks` 키에 템플릿 내용을 병합한다.
- `permissions`, `env` 등 기존 다른 키는 그대로 보존한다.
- `hooks` 키에 이미 내용이 있으면 덮어쓰기 전에 사용자 확인을 받는다.
- `.claude/settings.json`이 없거나 비어 있으면 `hooks` 키만 가진 파일로 새로 만든다.

기존 프로젝트 설정을 파괴하지 않는 것이 이 옵션의 전제다.

### 기존 파일 처리

- 설치 대상 파일이 없으면 그대로 복사한다.
- 설치 대상 파일이 이미 있고 비어 있으면 복사해 채운다.
- 설치 대상 파일이 이미 있고 내용이 있으면 덮어쓰기 전에 사용자 확인을 받는다. 이는 옵션 없는 init과 동일한 규칙이다.

### 지원 범위

현재 `--from-template`으로 설치할 수 있는 템플릿은 Claude(`adapters/claude/`)뿐이다.

Codex는 배포할 adapter 템플릿이 아직 없으므로 `codex dir init --from-template`은 기존과 동일한 빈 파일 생성으로 처리하고, 템플릿이 없다는 사실을 사용자에게 알린다.

## 생성 위치 기준

`.claude/`, `.codex/`, `.agents/` adapter 디렉토리는 **항상 프로젝트 루트**에 생성한다.

여기서 프로젝트 루트는 `--path` 옵션이 있으면 위 "--path 옵션" 기준으로 인식된 루트를, 옵션이 없으면 아래 케이스 판단에 따른 루트를 말한다.

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
- 프로젝트별 rule, skill이 생기면 하네스 import 아래에 `@.claude/rules/...`, `@.claude/skills/...` import를 추가할 수 있다. 하네스 import 한 줄은 유지하고, 프로젝트별 import는 그 아래에 둔다.

```md
@<submodule-path>/CLAUDE.md

@.claude/rules/example-rule.md
```

### codex dir init 시 — AGENTS.md 생성

프로젝트 루트에 `AGENTS.md`를 생성하고, 하네스 docs 파일 목록을 참조 안내로 포함한다.

이 목록은 Codex가 자동 import하는 대상이 아니라, 작업 중 필요할 때 읽어야 하는 문서 안내다.

```md
---
description: "Codex adapter 진입점입니다. 공통 협업 규칙은 아래 docs 문서를 기준으로 참조합니다."
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

## dir init

사용자가 `dir init`을 요청하면 현재 실행 중인 AI 환경을 먼저 판단한다.

| 현재 실행 AI 환경 | 처리 |
|---|---|
| Claude | `claude dir init`과 동일하게 처리 |
| Codex | `codex dir init`과 동일하게 처리 |
| 그 외 AI | 아래 "미지원 AI 처리" 기준을 따른다 |

현재 지원 AI는 Claude와 Codex로 제한한다.

## 미지원 AI 처리

Claude 또는 Codex가 아닌 신규 AI 환경에서 사용자가 `dir init`을 요청하면 adapter 구조를 임의로 생성하지 않는다.

다음 문구로 사용자에게 확인한다.

```text
현재 지원하지않는 AI 모델입니다. 공식문서를 참조해서 md 파일 과 설정 파일 구조를 md 추가할까요?
```

사용자가 동의하면 해당 AI의 공식 문서를 먼저 확인한 뒤, 다음 정보를 `docs/00-docs/03-agent-dir-init.md`와 실행 툴별 진입점 문서에 추가할지 검토한다.

- 프로젝트 지침 md 파일명과 로드 방식
- 설정 파일 또는 설정 디렉토리 위치
- rules, skills, agents, hooks 등 공식 지원 확장 위치
- `dir init`에서 생성할 starter adapter 구조
- 기존 Claude/Codex 구조와 충돌하지 않도록 제한할 금지 규칙

공식 문서로 확인되지 않은 구조는 생성 대상으로 추가하지 않는다.

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

이 저장소를 submodule 또는 공통 하네스로 pull 받은 사용자는 필요한 tool adapter만 init한다.

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
| `dir init` | 현재 실행 AI 환경이 Claude이면 `.claude/`, Codex이면 `.codex/`, `.agents/` 로컬 adapter 구조 생성 |
| `claude dir init` | `.claude/` 로컬 adapter 구조 생성 |
| `codex dir init` | `.codex/`, `.agents/` 로컬 adapter 구조 생성 |
| `dir init --path [경로]` | 현재 실행 AI 환경에 맞춰 지정 경로(생략 시 현재 위치)를 루트로 인식해 adapter 구조 생성 |
| `claude dir init --path [경로]` | 지정 경로(생략 시 현재 위치)를 루트로 인식해 `.claude/` 로컬 adapter 구조 생성 |
| `codex dir init --path [경로]` | 지정 경로(생략 시 현재 위치)를 루트로 인식해 `.codex/`, `.agents/` 로컬 adapter 구조 생성 |
| `dir init --from-template` | 현재 실행 AI 환경이 Claude이면 `adapters/claude/` 템플릿을 `.claude/`로 복사 설치 (빈 파일 생성 대신) |
| `claude dir init --from-template` | `adapters/claude/` 템플릿을 `.claude/`로 복사 설치, `settings.hooks.json`은 `.claude/settings.json`의 `hooks` 키에 병합 |
