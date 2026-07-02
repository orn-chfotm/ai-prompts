---
description: "docs 디렉토리와 현재 md 파일 구조를 설명하는 문서 관리 인덱스입니다."
---

# 00-docs 인덱스

이 디렉토리는 `docs` 전체 구조와 md 파일 작성 규칙을 관리한다.

최상위 `docs` 디렉토리에는 문서를 직접 두지 않고 대분류 디렉토리만 둔다.

## 대분류

- `00-docs/`: docs 구조, md 작성 규칙, 문서 탐색 기준
- `10-technical/`: Spring, naming, JavaScript 등 기술 규칙
- `20-ai-process/`: AI 역할 분담, 승인권, Agent 작동 방식
- `30-execution/`: 승인 이후 작업 진행 절차와 AI 엔지니어링
- `40-plan/`: 작업 plan 구조, 역할 간 소통, 실제 코드 산출 구조
- `50-review/`: 작업 마무리, review, test, 오류 처리

## 파일 목록

- `00.index.md`: 이 디렉토리의 목적과 전체 docs 대분류 설명
- `01-md-structure.md`: md 파일 구조, 번호 규칙, Agent 진입점 관리 기준
- `02-harness-boundary.md`: docs, `.codex`, `.claude`의 책임 경계와 commit 기준
- `03-agent-dir-init.md`: `codex dir init`, `claude dir init` 요청 시 생성할 Agent adapter 기본 구조

## 번호 규칙

- 대분류 디렉토리는 `00-*`, `10-*`, `20-*`처럼 10단위 번호를 사용한다.
- 대분류 하위 디렉토리는 `agents`, `roles`처럼 주제명만 사용한다.
- 각 디렉토리 안의 md 파일은 `00.index.md`, `01-*`, `02-*`처럼 1단위 번호를 사용한다.
- 각 디렉토리의 첫 파일은 반드시 `00.index.md`로 둔다.

## 핵심 방향

`docs`는 프로젝트에 이식 가능한 AI 하네스 엔지니어링 문서다.

`.codex`와 `.claude`는 각 Agent 실행 환경의 adapter 또는 프로젝트별 커스터마이징 위치다.

따라서 기본적으로 git에 공유할 공통 자산은 `docs`이며, `.codex`와 `.claude`는 모든 프로젝트에 공통으로 필요한 내용이 있을 때만 공유 대상으로 본다.

## 핵심 규칙 요약

- 사용자 최종 승인 전 파일 생성, 수정, 상태 변경 명령 실행을 하지 않는다.
- 모든 작업은 PM → CTO → PL → PA 흐름을 기본으로 한다.
- 파일 접근은 작업과 직접 관련된 범위로 제한하고, 범위 밖 파일은 먼저 사용자에게 설명하고 확인을 받는다.
- 리뷰 로그는 하네스 내부가 아닌 실제 프로젝트에 기록한다.