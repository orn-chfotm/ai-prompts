---
description: "Codex 전용 프로젝트 진입점입니다. docs 하위 대분류 문서를 기준으로 공통 협업 규칙을 참조합니다."
---

# AGENTS.md

이 파일은 Codex 전용 프로젝트 지침이다.

Codex는 공식적으로 `AGENTS.md`를 프로젝트 지침으로 읽는다. Claude 전용 `@path` import 문법은 이 파일에 사용하지 않는다.

아래 문서 목록은 자동 import 대상이 아니라, 작업 중 필요할 때 읽어야 하는 참조 안내다.

## 문서 구조 참조

- `docs/00-docs/00-index.md`
- `docs/00-docs/01-md-structure.md`
- `docs/00-docs/02-harness-boundary.md`
- `docs/00-docs/03-agent-dir-init.md`

## 기술 규칙 참조

- `docs/10-technical/00-index.md`
- `docs/10-technical/01-naming.md`
- `docs/10-technical/02-spring.md`
- `docs/10-technical/03-javascript.md`

## AI 처리 구조 참조

- `docs/20-ai-process/00-index.md`
- `docs/20-ai-process/agents/00-index.md`
- `docs/20-ai-process/agents/01-agent-entrypoints.md`
- `docs/20-ai-process/agents/02-role-model.md`
- `docs/20-ai-process/agents/03-approval-authority.md`
- `docs/20-ai-process/agents/roles/00-index.md`
- `docs/20-ai-process/agents/roles/01-pm.md`
- `docs/20-ai-process/agents/roles/02-cto.md`
- `docs/20-ai-process/agents/roles/03-pl.md`
- `docs/20-ai-process/agents/roles/04-pa.md`

## 실행 절차 참조

- `docs/30-execution/00-index.md`
- `docs/30-execution/01-workflow.md`
- `docs/30-execution/02-task-splitting.md`
- `docs/30-execution/03-output-format.md`

## Plan 및 산출 구조 참조

- `docs/40-plan/00-index.md`
- `docs/40-plan/01-plan-structure.md`
- `docs/40-plan/02-communication.md`
- `docs/40-plan/03-code-output.md`

## Review 및 테스트 참조

- `docs/50-review/00-index.md`
- `docs/50-review/01-review-process.md`
- `docs/50-review/02-test-policy.md`
- `docs/50-review/03-error-handling.md`
- `docs/50-review/04-review-logging.md`

## Codex 전용 규칙

- Codex 전용 설정은 `.codex/`에 둔다.
- Codex 전용 skill은 `.agents/skills/<skill-name>/SKILL.md`에 둔다.
- Codex 전용 custom agent는 `.codex/agents/<agent-name>.toml`에 둔다.
- Codex 전용 rule은 `.codex/rules/*.rules`에 둔다.
- Codex 전용 hook은 `.codex/hooks.json` 또는 `.codex/config.toml`의 `[hooks]`에 둔다.
- 공통 규칙은 `docs/`의 번호형 문서 구조에 유지하고, Codex 전용 문법을 공통 문서에 넣지 않는다.

## Codex dir init

사용자가 `codex dir init`을 요청하면 `docs/00-docs/03-agent-dir-init.md`의 "codex dir init" 기준을 단일 기준으로 따라 `.codex/`, `.agents/` 로컬 adapter 구조를 생성한다.

`.codex/skills/`는 생성하지 않는다. Codex skill은 `.agents/skills/<skill-name>/SKILL.md`에 둔다.

## dir init

사용자가 `dir init`을 요청하면 현재 실행 AI 환경이 Codex이므로 `codex dir init`과 동일하게 처리한다.

현재 자동 init을 지원하는 AI 환경은 Claude와 Codex로 제한한다.

Claude 또는 Codex가 아닌 신규 AI 환경에서 `dir init`을 요청하면 adapter 구조를 임의로 생성하지 않고 다음 문구로 사용자에게 확인한다.

```text
현재 지원하지않는 AI 모델입니다. 공식문서를 참조해서 md 파일 과 설정 파일 구조를 md 추가할까요?
```

사용자가 동의하면 해당 AI의 공식 문서를 먼저 확인한 뒤 md 파일, 설정 파일, rules, skills, agents, hooks 등 공식 지원 구조를 문서에 추가할지 검토한다.
