---
description: "AI 하네스 공통 구조와 Codex/Claude adapter 사용 규칙"
---

# AI 사용 공통 구조

이 저장소는 여러 프로젝트에서 재사용할 수 있는 AI 하네스 문서를 관리한다.

핵심 기준은 다음과 같다.

```text
docs
= 공통 AI 하네스
= 모든 프로젝트에서 우선 참조할 역할, 절차, 기술 원칙, 리뷰 기준

.codex
= Codex adapter
= Codex에서 docs 하네스를 실제로 연결하거나 확장하는 로컬/프로젝트별 설정

.agents
= Codex skills
= Codex가 repository skill을 탐색하는 위치

.claude
= Claude adapter
= Claude에서 docs 하네스를 실제로 연결하거나 확장하는 로컬/프로젝트별 설정
```

## 기본 원칙

- `docs`는 공통적으로 처리되어야 하는 AI 하네스 기준이다.
- `.codex`와 `.claude`는 프로젝트별 Agent 실행 환경을 조정하는 adapter다.
- `.agents/skills`는 Codex 전용 skill 위치다.
- 실제 프로젝트의 상세 구현 규칙, 인프라 구조, DB 제약, 리뷰어 역할은 필요한 경우 `.codex` 또는 `.claude`에 추가한다.
- `.codex`, `.claude`, `.agents`의 내용은 모든 프로젝트에 공통인 경우가 아니라면 commit하지 않는다.
- 반복적으로 여러 프로젝트에 필요해진 규칙은 `docs`로 승격한다.

이 저장소는 기본적으로 `.codex`, `.claude`, `.agents` 실제 디렉토리 구조를 commit하지 않는다.

사용자는 pull 받은 프로젝트에서 필요한 Agent에 맞게 `codex dir init` 또는 `claude dir init`을 요청해 로컬 adapter 구조를 생성한다.

## 실행 툴별 진입점

Claude와 Codex는 프로젝트 지침 파일명과 import 문법이 다르다.

따라서 모든 AI 툴을 아우르는 공통 상위 md를 별도로 만들지 않고, 실행 툴별 진입점을 분리한다.

| 실행 툴 | 프로젝트 루트 진입점 | 공통 하네스 진입점 |
|---|---|---|
| Claude | `CLAUDE.md` | `ai-prompts/CLAUDE.md` |
| Codex | `AGENTS.md` | `ai-prompts/AGENTS.md` |

Claude 프로젝트에서는 루트 `CLAUDE.md`가 `ai-prompts/CLAUDE.md`를 import한다.
Codex 프로젝트에서는 루트 `AGENTS.md`가 `ai-prompts/AGENTS.md`의 참조 구조를 따른다.

## docs 역할

`docs`는 다음 내용을 담당한다.

- AI가 어떤 역할 구조로 판단할지
- 사용자 승인, 거부, 보류, 재요청을 어떻게 처리할지
- 승인 후 작업을 어떤 절차로 진행할지
- plan, 소통, 코드 산출 구조를 어떻게 만들지
- 리뷰, 테스트, 오류, 로깅 기준을 어떻게 둘지
- Spring, naming, JavaScript 같은 공통 기술 원칙을 어떻게 둘지

최상위 `docs`에는 md 파일을 직접 두지 않고 대분류 디렉토리만 둔다.

```text
docs/
  00-docs/
  10-technical/
  20-ai-process/
  30-execution/
  40-plan/
  50-review/
```

## agents 규칙

`.claude/agents`와 `.codex/agents`는 추가 역할 기술이 필요한 경우에만 사용한다.

예를 들면 다음과 같은 전문 역할이 필요할 때 추가한다.

- DBA
- infrastructure architect
- security reviewer
- frontend reviewer
- backend reviewer
- implementation reviewer
- performance reviewer

agents는 단순 제한이 아니라, 특정 전문 관점과 판단 책임을 부여하는 위치다.

예시:

```text
docs/20-ai-process/agents/roles/02-cto.md
= CTO 역할의 공통 기준서

.codex/agents/infrastructure-architect.toml
= Codex에서 인프라 관점으로 판단할 실제 adapter

.claude/agents/infrastructure-architect.md
= Claude에서 인프라 관점으로 판단할 실제 adapter
```

## .codex 구조

Codex를 사용하는 프로젝트에서는 필요할 때 `codex dir init`을 요청해 다음 구조를 생성한다.

```text
.codex/
  config.toml
  hooks.json
  rules/
  agents/
.agents/
  skills/
```

### .codex/config.toml

Codex 프로젝트 설정을 둔다.

넣을 수 있는 내용의 예시는 다음과 같다.

- 모델 또는 reasoning 기본값
- sandbox, approval 관련 기본값
- MCP 서버 연결
- project-local Codex 설정

넣지 말아야 할 내용:

- 개인 인증 정보
- 프로젝트마다 달라지는 임시 실험 설정
- 모든 프로젝트에 공통이 아닌 개인 선호

### .codex/hooks.json

Codex lifecycle hook을 둔다.

hook을 `hooks.json`에 둘지 `.codex/config.toml`의 `[hooks]`에 둘지 선택할 수 있지만, 같은 layer에서는 한 방식만 사용하는 것을 권장한다.

넣을 수 있는 내용의 예시는 다음과 같다.

- tool 사용 전 검증
- turn 종료 후 검증
- prompt 제출 전 검사
- 프로젝트별 logging 또는 policy check

넣지 말아야 할 내용:

- 개인 인증 정보
- 외부 시스템을 무단으로 변경하는 자동화
- 공통으로 합의되지 않은 강제 hook

### .codex/rules

Codex가 항상 지켜야 하는 실행 제약을 둔다.

예시:

- 승인 전 파일 수정 금지
- 상태를 변경하는 특정 명령 실행 전 승인 필요
- critical 발견 시 `docs/50-review/04-review-logging.md` 기준 적용
- 프로젝트별 로그 위치 준수

### .agents/skills

Codex에서 반복 수행할 절차를 둔다.

skills는 역할이 아니라 절차다.

예시:

- architecture-review
- requirement-analysis
- implementation-plan
- code-review
- mybatis-query-review

skill은 `docs`의 원칙을 특정 작업 절차로 실행하기 위한 adapter다.

Codex skill은 `.codex/skills`가 아니라 `.agents/skills/<skill-name>/SKILL.md`에 둔다.

### .codex/agents

Codex에서 추가 전문 역할이 필요할 때 둔다.

예시:

- architecture-planner
- implementation-reviewer
- dba-reviewer
- infrastructure-architect

agent는 `docs`의 역할 기준을 실제 Codex 실행 역할로 연결한다.

## .claude 구조

Claude를 사용하는 프로젝트에서는 필요할 때 `claude dir init`을 요청해 다음 구조를 생성한다.

```text
.claude/
  settings.json
  rules/
  skills/
  agents/
```

### .claude/settings.json

Claude 프로젝트 설정을 둔다.

넣을 수 있는 내용의 예시는 다음과 같다.

- Claude Code 프로젝트 설정
- 권한 또는 도구 사용 기본값
- 프로젝트별 Claude 동작 설정

넣지 말아야 할 내용:

- 개인 인증 정보
- 모든 프로젝트에 공통이 아닌 개인 선호
- 임시 실험 설정

### .claude/rules

Claude가 항상 참고할 프로젝트별 규칙을 둔다.

예시:

- docs 하네스 우선 참조
- 승인 전 파일 수정 금지
- 리뷰 로그는 하네스 submodule 내부가 아니라 실제 프로젝트에 기록
- 기술 규칙은 `docs/10-technical`을 우선 확인

### .claude/skills

Claude에서 반복 수행할 절차를 둔다.

예시:

- architecture-review
- requirement-analysis
- implementation-plan
- code-review

skills는 `docs`의 절차를 Claude에서 반복 호출하기 쉽게 만드는 adapter다.

### .claude/agents

Claude에서 추가 전문 역할이 필요할 때 둔다.

예시:

- dba-reviewer
- security-reviewer
- infrastructure-architect
- implementation-reviewer

agents는 `docs`의 역할 기준을 Claude subagent로 연결한다.

## commit 기준

기본 commit 대상은 `docs`다.

`.codex`, `.claude`, `.agents`는 다음 조건을 만족할 때만 commit한다.

- 여러 프로젝트에서 동일하게 사용할 공통 adapter다.
- 개인 로컬 설정이 아니다.
- 실험용 설정이 아니다.
- 팀 또는 사용자 기준으로 공통 하네스 일부로 합의되었다.

그 외의 `.codex`, `.claude`, `.agents` 설정은 각 프로젝트 또는 로컬 환경에서만 사용한다.

## dir init 사용법

이 저장소를 pull 받은 뒤 필요한 Agent에 맞춰 다음처럼 요청한다.

Codex 기본 구조:

```text
codex dir init
```

생성 구조:

```text
.codex/
  config.toml
  hooks.json
  rules/
  agents/
.agents/
  skills/
```

Claude 기본 구조:

```text
claude dir init
```

생성 구조:

```text
.claude/
  settings.json
  rules/
  skills/
  agents/
```

init 결과물은 기본적으로 프로젝트별 로컬 adapter다.

공통 하네스로 합의되지 않았다면 commit하지 않는다.

## 사용 예시

Claude만 사용하는 프로젝트:

```text
docs/
.claude/
```

Codex만 사용하는 프로젝트:

```text
docs/
.codex/
.agents/
```

둘 다 사용하는 프로젝트:

```text
docs/
.codex/
.agents/
.claude/
```

공통 하네스만 submodule로 가져가고, 실제 adapter는 프로젝트에서 별도로 관리하는 것도 가능하다.

```text
docs/        # submodule 또는 공통 문서
.codex/      # 프로젝트별 Codex adapter
.agents/     # 프로젝트별 Codex skills
.claude/     # 프로젝트별 Claude adapter
```

## 확인 사항
- 이 경로가 프로젝트 루트 경로가 아닌 별도 폴더의 git sub module 이라면
