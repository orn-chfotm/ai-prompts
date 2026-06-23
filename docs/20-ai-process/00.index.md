---
description: "AI 역할 분담과 Agent 작동 방식을 관리하는 대분류 인덱스입니다."
---

# 20-ai-process 인덱스

이 디렉토리는 AI가 어떤 역할 구조로 판단하고 작동해야 하는지 정의한다.

핵심은 PM, CTO, PL, PA 역할 분담과 사용자 승인 구조다.

## 하위 디렉토리

- `agents/`: Agent 진입점, 역할 모델, 승인 권한, 역할별 상세 규칙

## 읽는 순서

1. `agents/00.index.md`
2. `agents/01-agent-entrypoints.md`
3. `agents/02-role-model.md`
4. `agents/03-approval-authority.md`
5. `agents/roles/00.index.md`
