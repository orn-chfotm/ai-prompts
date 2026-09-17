---
description: "docs와 tool adapter의 책임 경계와 commit 기준을 정의합니다."
---

# 하네스 경계

`docs`는 AI 하네스 엔지니어링 문서다.

이 문서들은 특정 Agent 실행 환경이 아니라, 모든 프로젝트에 이식 가능한 공통 사고 구조와 작업 절차를 정의한다.

## docs의 책임

`docs`는 다음 내용을 가진다.

- AI가 어떻게 역할을 나누고 판단할지
- 사용자가 어떻게 승인, 거부, 보류, 재요청을 할지
- 승인 이후 작업을 어떤 절차로 진행할지
- plan, 소통, 코드 산출 구조를 어떻게 만들지
- 리뷰, 테스트, 오류 처리를 어떤 기준으로 할지
- 기술 규칙의 공통 원칙을 어떻게 둘지

`docs`는 특정 Agent의 실행 설정 파일을 대신하지 않는다.

## tool adapter의 책임

tool adapter는 특정 AI tool의 실행 환경을 조정하는 영역이다.

예시는 다음과 같다.

- tool별 project config
- tool별 custom agent 또는 subagent
- tool별 hook, rule, skill
- tool별 문서 로딩 방식 연결

adapter는 위치에 따라 두 종류로 구분한다. 이 둘은 commit 기준이 서로 다르므로 섞어서 판단하지 않는다.

### 1. 프로젝트 로컬 adapter

각 프로젝트 루트의 `.claude/`, `.codex/`, `.agents/`가 여기에 해당한다.

- 프로젝트마다 내용이 달라지는 실제 실행 설정이다.
- 하네스 저장소에 commit하지 않는다.
- 프로젝트 자신의 repository에서 관리한다.
- `dir init`으로 생성하거나 adapter 템플릿에서 복사해 설치한다.

### 2. 하네스가 배포하는 adapter 템플릿

하네스 저장소 최상위 `adapters/<tool>/`가 여기에 해당한다. 예: `adapters/claude/`.

- 여러 프로젝트가 동일하게 쓰도록 하네스가 제공하는 **배포용 템플릿**이며, 하네스의 1급 산출물이다.
- 따라서 하네스 저장소의 commit 대상이다.
- 프로젝트는 여기서 파일을 자기 `.claude/` 등 프로젝트 로컬 adapter로 복사해 설치한다. 복사 매핑과 설치 절차는 `03-agent-dir-init.md`의 `--from-template` 기준을 따른다.
- 템플릿을 복사해 설치한 결과물은 다시 "프로젝트 로컬 adapter"이므로 하네스에 되돌려 commit하지 않는다.

현재 배포하는 템플릿은 다음과 같다.

```text
adapters/claude/
  agents/{pm,cto,pl,pa}.md
  hooks/{subagent-stop-flag.sh,check-pa-callback.sh}
  settings.hooks.json
  rules/01-workflow-gate.md
  skills/ai-process-workflow/SKILL.md
  README.md
```

### 현재 프로젝트 로컬 adapter 예시

- Codex: `.codex/`, `.agents/`
- Claude: `.claude/`

Codex skill은 `.codex`가 아니라 `.agents/skills`에 둔다.

`.agents/skills`는 Codex가 repository skill을 탐색하는 위치다.

## bundles의 책임

하네스 저장소 최상위 `bundles/<name>/`은 특정 기술 스택 전용 상세 규칙 묶음이다.

- `docs`가 tool과 스택에 중립적인 공통 원칙을 담는 반면, `bundles`는 스택별 구체 규칙을 담는다.
- 모든 프로젝트가 로드하지 않고, 해당 스택을 쓰는 프로젝트만 선택적으로 로드한다.
- `adapters`와 마찬가지로 하네스의 1급 산출물이며 commit 대상이다.
- 로드 방식과 번들 추가 규칙은 `04-loading-profile.md`를 따른다.

## commit 기준

기본 commit 대상은 `docs`, `adapters`, `bundles`다. 이 셋은 모두 하네스의 1급 산출물이다.

프로젝트 로컬 adapter(`.codex`, `.claude`, `.agents`)는 다음 조건을 모두 만족할 때만 예외적으로 commit한다.

- 여러 프로젝트에서 동일하게 사용해야 한다.
- 개인 로컬 설정이 아니다.
- 실험용 설정이 아니다.
- 팀 또는 사용자 기준으로 공통 하네스의 일부로 합의되었다.

여러 프로젝트에서 반복 사용할 가치가 확인된 tool 실행 자산은, 프로젝트 로컬 adapter를 commit하는 대신 `adapters/<tool>/` 템플릿으로 승격하는 것을 우선한다.

## 금지 기준

다음 내용은 `docs`에 넣지 않는다.

- 특정 프로젝트의 세부 구현 결정
- 개인 로컬 환경 설정
- 비밀값, 토큰, 인증 정보
- 한 tool에서만 동작하는 실행 설정
- 임시 실험용 skill 또는 rule
- 특정 스택에서만 성립하는 상세 구현 규칙

이 금지 기준은 `adapters/`가 생긴 뒤에도 그대로 유지한다. tool 전용 문법과 실행 설정을 `docs`에서 걷어내 `adapters/`에 모으는 것이 adapter 분리의 목적이므로, `docs`에 tool 전용 내용을 다시 넣지 않는다. 스택 전용 상세 규칙은 같은 이유로 `bundles/`에 둔다.

## 권장 흐름

1. 공통 원칙은 `docs`에 작성한다.
2. 프로젝트별 적용 방식은 해당 프로젝트의 tool adapter에 작성한다.
3. Codex skill은 `.agents/skills`에 작성한다.
4. 여러 프로젝트에 반복 적용할 가치가 생기면 `docs`로 승격한다. 단, tool 전용 실행 자산이면 `docs`가 아니라 `adapters/<tool>/`로, 스택 전용 규칙이면 `bundles/<name>/`으로 승격한다.
5. tool별 실행 adapter가 필요하면 각 tool adapter 디렉토리에 별도로 둔다.
