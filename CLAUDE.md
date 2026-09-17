---
description: "Claude 전용 하네스 코어 진입점입니다. 상단의 @ import로 코어 공통 협업 규칙만 로드합니다."
---

@docs/00-docs/01-md-structure.md
@docs/00-docs/02-harness-boundary.md
@docs/00-docs/03-agent-dir-init.md
@docs/00-docs/04-loading-profile.md
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

이 파일은 Claude 전용 하네스 진입점이다.

Claude는 공식적으로 `CLAUDE.md`의 `@path` import를 지원하므로, 공통 문서는 이 파일 상단에서 명시적으로 import한다.

## 이 파일은 코어만 로드한다

상단 import 목록은 **코어 문서만** 포함한다. 코어는 tool과 기술 스택에 무관하게 모든 프로젝트가 항상 로드해야 하는 문서다.

- 포함: `docs/00-docs/*`, `docs/20-ai-process/**`, `docs/30-execution/*`, `docs/40-plan/*`, `docs/50-review/*`
- 제외: `docs/10-technical/*`(스택별 추상 원칙), `bundles/*`(스택별 상세 규칙 묶음)

제외된 문서는 삭제된 것이 아니라 선택 로드 대상이다. JavaScript를 쓰지 않는 프로젝트가 JavaScript 규칙을 매 세션 로드하지 않게 하려는 분리다.

기준은 `docs/00-docs/04-loading-profile.md`를 따른다.

## 스택 번들 추가 로드

스택 번들이 필요한 프로젝트는 프로젝트 루트 `CLAUDE.md`에서 번들 index를 한 줄 더 import한다.

```md
@.ai-prompts/CLAUDE.md                                   ← 코어 (필수)
@.ai-prompts/bundles/spring-jpa-multimodule/00-index.md  ← 스택 번들 (선택)
@.claude/rules/...                                       ← 프로젝트 고유
```

첫 줄(코어)은 항상 유지하고, 번들과 프로젝트 고유 규칙은 그 아래에 둔다.

번들에는 그 번들을 만든 프로젝트의 고유 결정(디렉토리명, 모듈명 등)이 섞여 있을 수 있으므로 그대로 적용하지 않고 참고 기준으로 사용한다.

## Claude adapter 설치

하네스는 Claude 실행 자산(subagent 정의, hook, 워크플로우 게이트 rule, skill, hook 설정)을 `adapters/claude/`에 템플릿으로 배포한다.

프로젝트에 설치하려면 `claude dir init --from-template`을 요청한다. 복사 매핑과 `settings.hooks.json` 병합 기준은 `docs/00-docs/03-agent-dir-init.md`의 "--from-template 옵션"을 따른다.

자세한 내용은 `adapters/claude/README.md`를 참고한다.

## Claude 전용 규칙

- Claude 전용 설정은 `.claude/`에 둔다.
- Claude 전용 rule은 `.claude/rules/`에 둔다.
- Claude 전용 skill은 `.claude/skills/<skill-name>/SKILL.md`에 둔다.
- Claude 전용 subagent는 `.claude/agents/<agent-name>.md`에 둔다.
- 공통 규칙은 `docs/`의 번호형 문서 구조에 유지하고, Claude 전용 문법은 공통 문서에 넣지 않는다.
- 여러 프로젝트에 공통으로 배포할 Claude 실행 자산은 `adapters/claude/`에 템플릿으로 둔다. 프로젝트 로컬 `.claude/`는 하네스에 commit하지 않는다.

## Claude dir init

사용자가 `claude dir init`을 요청하면 `docs/00-docs/03-agent-dir-init.md`의 "claude dir init" 기준을 단일 기준으로 따라 `.claude/` 로컬 adapter 구조를 생성한다.

기본 동작은 빈 파일 생성이다. 사용자가 `claude dir init --from-template`을 요청하면 빈 파일 대신 `adapters/claude/` 템플릿을 `.claude/`로 복사 설치한다. 이때 `settings.hooks.json`은 `.claude/settings.json`을 덮어쓰지 않고 그 파일의 `hooks` 키에 병합한다. 기준은 `docs/00-docs/03-agent-dir-init.md`의 "--from-template 옵션"을 따른다.

## dir init

사용자가 `dir init`을 요청하면 현재 실행 AI 환경이 Claude이므로 `claude dir init`과 동일하게 처리한다. `--path`, `--from-template` 옵션도 동일하게 적용한다.

현재 자동 init을 지원하는 AI 환경은 Claude와 Codex로 제한한다.

Claude 또는 Codex가 아닌 신규 AI 환경에서 `dir init`을 요청하면 adapter 구조를 임의로 생성하지 않고 다음 문구로 사용자에게 확인한다.

```text
현재 지원하지않는 AI 모델입니다. 공식문서를 참조해서 md 파일 과 설정 파일 구조를 md 추가할까요?
```

사용자가 동의하면 해당 AI의 공식 문서를 먼저 확인한 뒤 md 파일, 설정 파일, rules, skills, agents, hooks 등 공식 지원 구조를 문서에 추가할지 검토한다.
