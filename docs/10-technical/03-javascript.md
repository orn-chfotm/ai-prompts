---
description: "JavaScript와 TypeScript 프로젝트에서 적용할 기술 규칙의 초안입니다."
---

# JavaScript 규칙

JavaScript 또는 TypeScript 프로젝트에서 사용하는 기술 규칙을 이 문서에 정리한다.

## 기본 원칙

- 기존 lint, formatter, module 규칙을 우선한다.
- 타입이 있는 프로젝트에서는 `any` 사용을 피하고 의도를 드러낸다.
- 상태 관리, API 호출, UI 컴포넌트 책임을 분리한다.
- 비동기 오류 처리는 호출자와 사용자 경험을 함께 고려한다.
- 테스트 가능성을 해치지 않는 구조를 우선한다.

## Agent 적용 기준

CTO는 상태 관리, 렌더링 성능, API 계약, 빌드 영향도를 검토한다.

PL은 컴포넌트 경계, hook/util 분리, 테스트 범위를 정한다.

PA는 기존 스타일과 타입 규칙을 따른다.
