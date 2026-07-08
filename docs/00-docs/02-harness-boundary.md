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

이 내용은 프로젝트마다 달라질 수 있으므로, 모든 프로젝트에 공통으로 필요한 경우가 아니라면 commit 대상으로 보지 않는다.

### 현재 adapter 예시

- Codex: `.codex/`, `.agents/`
- Claude: `.claude/`

Codex skill은 `.codex`가 아니라 `.agents/skills`에 둔다.

`.agents/skills`는 Codex가 repository skill을 탐색하는 위치다.

## commit 기준

기본 commit 대상은 `docs`다.

tool adapter는 다음 조건을 만족할 때만 commit한다.

- 여러 프로젝트에서 동일하게 사용해야 한다.
- 개인 로컬 설정이 아니다.
- 실험용 설정이 아니다.
- 팀 또는 사용자 기준으로 공통 하네스의 일부로 합의되었다.

## 금지 기준

다음 내용은 `docs`에 넣지 않는다.

- 특정 프로젝트의 세부 구현 결정
- 개인 로컬 환경 설정
- 비밀값, 토큰, 인증 정보
- 한 tool에서만 동작하는 실행 설정
- 임시 실험용 skill 또는 rule

## 권장 흐름

1. 공통 원칙은 `docs`에 작성한다.
2. 프로젝트별 적용 방식은 해당 프로젝트의 tool adapter에 작성한다.
3. Codex skill은 `.agents/skills`에 작성한다.
4. 여러 프로젝트에 반복 적용할 가치가 생기면 `docs`로 승격한다.
5. tool별 실행 adapter가 필요하면 각 tool adapter 디렉토리에 별도로 둔다.
