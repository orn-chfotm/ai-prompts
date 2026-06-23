---
description: "AI Agent 역할 구조와 승인 체계 문서의 인덱스입니다."
---

# agents 인덱스

이 디렉토리는 AI가 어떤 역할로 나뉘고 어떤 순서로 판단해야 하는지 정의한다.

## 파일 목록

- `01-agent-entrypoints.md`: Codex와 Claude의 공식 진입점 참조 방식
- `02-role-model.md`: PM, CTO, PL, PA 역할 모델
- `03-approval-authority.md`: 사용자 승인권과 승인 게이트
- `roles/`: 역할별 상세 능력치와 책임

## 역할

이 디렉토리는 작업 실행 절차 자체보다, 실행 전에 필요한 AI 역할 구조와 판단 방식을 정의한다.

승인 이후 실제 작업 진행 절차는 `docs/30-execution/`에서 관리한다.

작업 plan과 코드 산출 구조는 `docs/40-plan/`에서 관리한다.
