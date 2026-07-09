---
description: "AI tool adapter가 docs 하위 공통 문서를 각자의 로딩 방식에 맞게 참조하는 방법입니다."
---

# Agent 진입점 연결 예시

이 문서는 `docs` 하네스를 AI tool adapter에서 어떻게 연결할 수 있는지 보여주는 예시다.

실제 `AGENTS.md`, `CLAUDE.md`, `.codex`, `.claude` 파일을 이 문서가 직접 관리하지 않는다.

AI tool은 서로 다른 공식 로딩 방식을 사용할 수 있으므로, 프로젝트별 adapter에서 `docs`를 연결한다.

아래 Codex와 Claude는 현재 제공하는 adapter 예시다. 새 tool을 추가할 때도 `docs` 본문에 tool 전용 문법을 넣지 않고, 별도 adapter 진입점에서 `docs`를 연결한다.

## Codex

Codex는 프로젝트 지침으로 `AGENTS.md`를 읽는다.

Codex용 `AGENTS.md`는 공통 문서를 직접 import하는 문법을 가정하지 않는다. 대신 참조 문서 목록으로 `docs` 하네스를 안내한다.

이 참조 문서 목록은 자동 로드 대상이 아니라, Codex가 작업 중 필요할 때 읽어야 하는 문서 안내다.

예시:

```md
---
description: "Codex 전용 프로젝트 진입점입니다. 공통 협업 규칙은 docs 문서를 기준으로 참조합니다."
---

# AGENTS.md

## 참조 문서

- docs/00-docs/01-md-structure.md
- docs/20-ai-process/agents/02-role-model.md
- docs/20-ai-process/agents/03-approval-authority.md
- docs/30-execution/01-workflow.md
- docs/40-plan/01-plan-structure.md
- docs/50-review/01-review-process.md
```

Codex의 반복 작업 절차나 custom agent가 필요하면 프로젝트의 `.codex` adapter에서 별도로 작성한다.

그 내용은 모든 프로젝트에 공통으로 필요한 경우가 아니라면 `docs` 하네스와 별도로 관리한다.

## Claude

Claude는 `CLAUDE.md`에서 `@path` import를 사용할 수 있다.

Claude용 `CLAUDE.md`는 상단에 공통 문서를 명시적으로 import한다.

예시:

```md
@docs/00-docs/01-md-structure.md
@docs/20-ai-process/agents/02-role-model.md
@docs/20-ai-process/agents/03-approval-authority.md
@docs/30-execution/01-workflow.md
@docs/40-plan/01-plan-structure.md
@docs/50-review/01-review-process.md

# CLAUDE.md

## Claude 전용 규칙

- Claude 전용 실행 방식은 이 아래에 작성한다.
```

Claude의 모듈형 규칙, skill, subagent가 필요하면 프로젝트의 `.claude` adapter에서 별도로 작성한다.

그 내용은 모든 프로젝트에 공통으로 필요한 경우가 아니라면 `docs` 하네스와 별도로 관리한다.

## 금지 사항

- `CLAUDE.md`가 `AGENTS.md`를 import하는 방식은 이 하네스의 기본 구조로 사용하지 않는다.
- `AGENTS.md`에 Claude 전용 `@path` import 문법을 넣지 않는다.
- 공통 문서에 특정 tool만 이해하는 설정 문법을 넣지 않는다.
- `.codex` 또는 `.claude`의 로컬 설정을 공통 하네스 규칙처럼 `docs`에 복사하지 않는다.

## 새 adapter 추가 기준

- 새 tool의 공식 프로젝트 지침 파일명과 로딩 방식을 확인한다.
- `docs` 하위 공통 문서를 tool이 읽을 수 있는 방식으로 연결한다.
- tool 전용 설정, hook, skill, agent는 해당 tool adapter에 둔다.
- 여러 tool에서 공유할 수 있는 원칙만 `docs`로 승격한다.

새 tool에서 `dir init`을 지원하려면 해당 tool의 공식 문서를 먼저 확인하고, `docs/00-docs/03-agent-dir-init.md`에 md 파일, 설정 파일, rules, skills, agents, hooks 등 공식 지원 구조와 금지 규칙을 추가한다.

공식 문서로 확인되지 않은 구조는 init 생성 대상으로 추가하지 않는다.
