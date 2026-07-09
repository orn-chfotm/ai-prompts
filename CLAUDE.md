---
description: "Claude 전용 프로젝트 진입점입니다. 상단의 @ import로 docs 하위 공통 협업 규칙을 로드합니다."
---

@docs/00-docs/01-md-structure.md
@docs/00-docs/02-harness-boundary.md
@docs/00-docs/03-agent-dir-init.md
@docs/10-technical/01-naming.md
@docs/10-technical/02-spring.md
@docs/10-technical/03-javascript.md
@docs/20-ai-process/agents/01-agent-entrypoints.md
@docs/20-ai-process/agents/02-role-model.md
@docs/20-ai-process/agents/03-approval-authority.md
@docs/20-ai-process/agents/roles/01-pm.md
@docs/20-ai-process/agents/roles/02-cto.md
@docs/20-ai-process/agents/roles/03-pl.md
@docs/20-ai-process/agents/roles/04-pa.md
@docs/30-execution/01-workflow.md
@docs/30-execution/02-task-splitting.md
@docs/30-execution/03-output-format.md
@docs/40-plan/01-plan-structure.md
@docs/40-plan/02-communication.md
@docs/40-plan/03-code-output.md
@docs/50-review/01-review-process.md
@docs/50-review/02-test-policy.md
@docs/50-review/03-error-handling.md
@docs/50-review/04-review-logging.md

# CLAUDE.md

이 파일은 Claude 전용 프로젝트 지침이다.

Claude는 공식적으로 `CLAUDE.md`의 `@path` import를 지원하므로, 공통 문서는 이 파일 상단에서 명시적으로 import한다.

## Claude 전용 규칙

- Claude 전용 설정은 `.claude/`에 둔다.
- Claude 전용 rule은 `.claude/rules/`에 둔다.
- Claude 전용 skill은 `.claude/skills/<skill-name>/SKILL.md`에 둔다.
- Claude 전용 subagent는 `.claude/agents/<agent-name>.md`에 둔다.
- 공통 규칙은 `docs/`의 번호형 문서 구조에 유지하고, Claude 전용 문법은 공통 문서에 넣지 않는다.

## Claude dir init

사용자가 `claude dir init`을 요청하면 `docs/00-docs/03-agent-dir-init.md`의 "claude dir init" 기준을 단일 기준으로 따라 `.claude/` 로컬 adapter 구조를 생성한다.

## dir init

사용자가 `dir init`을 요청하면 현재 실행 AI 환경이 Claude이므로 `claude dir init`과 동일하게 처리한다.

현재 자동 init을 지원하는 AI 환경은 Claude와 Codex로 제한한다.

Claude 또는 Codex가 아닌 신규 AI 환경에서 `dir init`을 요청하면 adapter 구조를 임의로 생성하지 않고 다음 문구로 사용자에게 확인한다.

```text
현재 지원하지않는 AI 모델입니다. 공식문서를 참조해서 md 파일 과 설정 파일 구조를 md 추가할까요?
```

사용자가 동의하면 해당 AI의 공식 문서를 먼저 확인한 뒤 md 파일, 설정 파일, rules, skills, agents, hooks 등 공식 지원 구조를 문서에 추가할지 검토한다.
