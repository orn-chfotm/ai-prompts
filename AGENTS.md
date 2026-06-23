---
description: "Codex 전용 프로젝트 진입점입니다. docs 하위 대분류 문서를 기준으로 공통 협업 규칙을 참조합니다."
---

# AGENTS.md

이 파일은 Codex 전용 프로젝트 지침이다.

Codex는 공식적으로 `AGENTS.md`를 프로젝트 지침으로 읽는다. Claude 전용 `@path` import 문법은 이 파일에 사용하지 않는다.

## 문서 구조 참조

- `docs/00-docs/00.index.md`
- `docs/00-docs/01-md-structure.md`

## 기술 규칙 참조

- `docs/10-technical/00.index.md`
- `docs/10-technical/01-naming.md`
- `docs/10-technical/02-spring.md`
- `docs/10-technical/03-javascript.md`

## AI 처리 구조 참조

- `docs/20-ai-process/00.index.md`
- `docs/20-ai-process/agents/00.index.md`
- `docs/20-ai-process/agents/01-agent-entrypoints.md`
- `docs/20-ai-process/agents/02-role-model.md`
- `docs/20-ai-process/agents/03-approval-authority.md`
- `docs/20-ai-process/agents/roles/00.index.md`
- `docs/20-ai-process/agents/roles/01-pm.md`
- `docs/20-ai-process/agents/roles/02-cto.md`
- `docs/20-ai-process/agents/roles/03-pl.md`
- `docs/20-ai-process/agents/roles/04-pa.md`

## 실행 절차 참조

- `docs/30-execution/00.index.md`
- `docs/30-execution/01-workflow.md`
- `docs/30-execution/02-task-splitting.md`
- `docs/30-execution/03-output-format.md`

## Plan 및 산출 구조 참조

- `docs/40-plan/00.index.md`
- `docs/40-plan/01-plan-structure.md`
- `docs/40-plan/02-communication.md`
- `docs/40-plan/03-code-output.md`

## Review 및 테스트 참조

- `docs/50-review/00.index.md`
- `docs/50-review/01-review-process.md`
- `docs/50-review/02-test-policy.md`
- `docs/50-review/03-error-handling.md`
- `docs/50-review/04-review-logging.md`

## Codex 전용 규칙

- Codex 전용 설정은 `.codex/`에 둔다.
- Codex 전용 skill은 `.codex/skills/<skill-name>/SKILL.md`에 둔다.
- Codex 전용 custom agent는 `.codex/agents/<agent-name>.toml`에 둔다.
- 공통 규칙은 `docs/`의 번호형 문서 구조에 유지하고, Codex 전용 문법을 공통 문서에 넣지 않는다.
