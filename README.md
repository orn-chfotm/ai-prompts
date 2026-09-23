---
description: "AI 하네스 공통 구조와 tool adapter 사용 규칙"
---

# AI 사용 공통 구조

이 저장소는 여러 프로젝트에서 재사용할 수 있는 AI 하네스 문서를 관리한다.

핵심 기준은 다음과 같다.

```text
docs
= 공통 AI 하네스 (코어)
= 모든 프로젝트에서 항상 로드할 역할, 절차, 기술 원칙, 리뷰 기준
= tool 중립. 특정 tool 전용 문법과 실행 설정을 넣지 않는다

adapters
= tool별 실행 자산 배포 템플릿
= subagent 정의, hook, 설정, rule, skill처럼 특정 tool에서만 동작하는 자산
= 하네스의 1급 산출물이며 commit 대상
= 프로젝트는 여기서 복사해 자기 .claude/ 등에 설치한다

bundles
= 스택별 상세 규칙 묶음
= 해당 스택을 쓰는 프로젝트만 선택 로드
= 하네스의 1급 산출물이며 commit 대상

.codex
= Codex adapter
= Codex에서 docs 하네스를 실제로 연결하거나 확장하는 로컬/프로젝트별 설정

.agents
= Codex skills
= Codex가 repository skill을 탐색하는 위치

.claude
= Claude 프로젝트 로컬 adapter
= Claude에서 docs 하네스를 실제로 연결하거나 확장하는 로컬/프로젝트별 설정
```

`adapters`(하네스가 배포하는 템플릿)와 `.claude`/`.codex`(프로젝트 로컬 설정)는 서로 다른 것이다. 전자는 commit 대상이고, 후자는 아니다.

## 로딩 프로파일

모든 프로젝트가 모든 문서를 로드하지 않는다.

- 코어(항상 로드): `docs/00-docs/*`, `docs/20-ai-process/**`, `docs/30-execution/*`, `docs/40-plan/*`, `docs/50-review/*`
- 선택(필요할 때만): `docs/10-technical/*`, `bundles/*`

하네스의 `CLAUDE.md`는 코어만 import한다. 스택 번들이 필요하면 프로젝트 루트 `CLAUDE.md`에서 번들 index를 한 줄 더 import한다.

```md
@.ai-prompts/CLAUDE.md                                   ← 코어 (필수)
@.ai-prompts/bundles/spring-jpa-multimodule/00-index.md  ← 스택 번들 (선택)
@.claude/rules/...                                       ← 프로젝트 고유
```

Codex는 `@import`가 없으므로 `AGENTS.md`의 참조 문서 목록에 번들 index 경로를 추가해 같은 효과를 낸다.

자세한 기준은 `docs/00-docs/04-loading-profile.md`를 따른다.

## 기본 원칙

- `docs`는 공통적으로 처리되어야 하는 tool 중립 AI 하네스 기준이다.
- `adapters`는 tool별 실행 자산의 배포 템플릿이며, tool 전용 문법이 허용되는 유일한 위치다.
- `bundles`는 스택별 상세 규칙 묶음이며, 해당 스택을 쓰는 프로젝트만 로드한다.
- 프로젝트 로컬 adapter는 프로젝트별 Agent 실행 환경을 조정한다.
- 현재 기본 프로젝트 로컬 adapter는 Codex(`.codex`, `.agents`)와 Claude(`.claude`)를 제공한다.
- 현재 배포하는 adapter 템플릿은 Claude(`adapters/claude/`)뿐이다.
- `dir init`은 현재 실행 중인 AI 환경이 Claude인지 Codex인지 판단해 해당 adapter 구조를 생성한다.
- 현재 `dir init` 자동 처리는 Claude와 Codex에서만 지원한다.
- 실제 프로젝트의 상세 구현 규칙, 인프라 구조, DB 제약, 리뷰어 역할은 필요한 경우 해당 프로젝트 로컬 adapter에 추가한다.
- 프로젝트 로컬 adapter의 내용은 모든 프로젝트에 공통인 경우가 아니라면 commit하지 않는다.
- 반복적으로 여러 프로젝트에 필요해진 규칙은 `docs`로 승격한다. 다만 tool 전용 실행 자산은 `adapters/<tool>/`로, 스택 전용 규칙은 `bundles/<name>/`으로 승격한다.

이 저장소는 프로젝트 로컬 adapter 디렉토리(`.claude`, `.codex`, `.agents`)를 commit하지 않는다.

사용자는 pull 받은 프로젝트에서 `dir init` 또는 명시적인 tool별 dir init 명령을 요청해 로컬 adapter 구조를 생성한다.

Claude 실행 자산을 빈 파일이 아니라 하네스 템플릿으로 설치하려면 `claude dir init --from-template`을 요청한다.

## 실행 툴별 진입점

AI tool마다 프로젝트 지침 파일명과 import 문법이 다를 수 있다.

따라서 모든 AI 툴을 아우르는 공통 상위 md를 별도로 만들지 않고, 실행 툴별 진입점을 분리한다.

현재 제공하는 adapter는 다음과 같다.

| 실행 툴 | 프로젝트 루트 진입점 | 공통 하네스 진입점 |
|---|---|---|
| Claude | `CLAUDE.md` | `ai-prompts/CLAUDE.md` |
| Codex | `AGENTS.md` | `ai-prompts/AGENTS.md` |

Claude 프로젝트에서는 루트 `CLAUDE.md`가 `ai-prompts/CLAUDE.md`를 import한다.
Codex 프로젝트에서는 루트 `AGENTS.md`가 `ai-prompts/AGENTS.md`의 참조 안내 구조를 따른다.
Codex의 참조 문서 목록은 자동 import 대상이 아니라, 작업 중 필요할 때 읽어야 하는 문서 안내다.
새 tool을 추가할 때는 `docs`를 수정하기보다 해당 tool의 adapter 진입점과 로딩 방식을 별도로 정의한다.

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

하네스 저장소 최상위 전체 구조는 다음과 같다.

```text
<harness-root>/
  CLAUDE.md          코어만 import하는 Claude 진입점
  AGENTS.md          Codex용 코어 참조 목록
  README.md
  docs/              tool 중립 공통 원칙 (코어)
  adapters/
    claude/          Claude 실행 자산 배포 템플릿
  bundles/
    <name>/          스택별 상세 규칙 묶음 (선택 로드)
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

## 현재 지원 adapter: Codex

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

## 현재 지원 adapter: Claude

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

## adapters: Claude 배포 템플릿

`adapters/claude/`는 하네스가 배포하는 Claude 실행 자산 템플릿이다. 프로젝트 로컬 `.claude/`와 달리 이 저장소의 commit 대상이다.

```text
adapters/claude/
  agents/{pm,cto,pl,pa,prompter,reviewer}.md
  hooks/{subagent-stop-flag.sh,check-pa-callback.sh,check-pa-review.cjs}
  settings.hooks.json
  rules/{01-workflow-gate,02-agent-review}.md
  skills/ai-process-workflow/SKILL.md
  README.md
```

설치는 `claude dir init --from-template`으로 한다. 복사 매핑과 `settings.hooks.json` 병합 기준은 `docs/00-docs/03-agent-dir-init.md`의 "--from-template 옵션"을 따른다.

Codex용 배포 템플릿은 아직 없다.

## bundles: 스택별 규칙 묶음

`bundles/<name>/`은 특정 기술 스택 전용 상세 규칙 묶음이다. 진입점은 `bundles/<name>/00-index.md`이며, 프로젝트는 이 index 한 줄만 연결한다.

번들에는 그 번들을 만든 프로젝트의 고유 결정(디렉토리명, 모듈명 등)이 섞여 있을 수 있으므로 그대로 적용하지 않고 참고 기준으로 사용한다.

번들 추가 규칙은 `docs/00-docs/04-loading-profile.md`를 따른다.

## commit 기준

기본 commit 대상은 `docs`, `adapters`, `bundles`다.

`.codex`, `.claude`, `.agents`처럼 프로젝트 로컬 adapter의 commit 조건은 `docs/00-docs/02-harness-boundary.md`의 "commit 기준"을 단일 기준으로 따른다.

## dir init 사용법

이 저장소를 pull 받은 뒤 현재 실행 AI 환경에 맞춰 자동 생성하려면 `dir init`을 요청한다.

명시적으로 지정하려면 `codex dir init` 또는 `claude dir init`을 요청한다.

기본 동작은 빈 파일 생성이다. Claude 실행 자산을 하네스 템플릿으로 채워 설치하려면 `claude dir init --from-template`을 요청한다.

현재 자동 init을 지원하는 AI 환경은 Claude와 Codex로 제한한다.

Claude 또는 Codex가 아닌 신규 AI 환경에서 `dir init`을 요청하면 다음 확인을 먼저 거친다.

```text
현재 지원하지않는 AI 모델입니다. 공식문서를 참조해서 md 파일 과 설정 파일 구조를 md 추가할까요?
```

생성 구조, 생성 위치, 기존 파일 처리 기준은 `docs/00-docs/03-agent-dir-init.md`를 단일 기준으로 따른다.

init 결과물은 기본적으로 프로젝트별 로컬 adapter다.

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

이 하네스를 프로젝트 루트가 아닌 별도 하위 폴더의 git submodule로 사용하는 경우의 adapter 생성 위치와 진입점 md 생성 기준은 `docs/00-docs/03-agent-dir-init.md`의 "생성 위치 기준"을 따른다.
