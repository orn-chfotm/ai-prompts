---
description: "Spring 및 Spring Boot 프로젝트에서 적용할 기술 규칙의 초안입니다."
---

# Spring 규칙

Spring 또는 Spring Boot 프로젝트에서 사용하는 기술 규칙을 이 문서에 정리한다.

## 기본 원칙

- Controller, Service, Repository의 책임을 섞지 않는다.
- 트랜잭션 경계는 Service 계층에서 명확히 검토한다.
- DTO, Entity, Request, Response 모델의 역할을 구분한다.
- 예외 처리 방식은 프로젝트의 기존 패턴을 따른다.
- 테스트는 슬라이스 테스트와 통합 테스트의 목적을 구분한다.

## 상세 규칙 번들

이 문서는 스택 중립적인 원칙만 둔다.

Spring Boot 3 + JPA + QueryDSL + Gradle 멀티모듈(포트-어댑터 분리) 스택에서 패키지 구조, Entity/DTO/예외/QueryDSL/보안 작성 규칙까지 구체적으로 필요하면 `bundles/spring-jpa-multimodule/00-index.md`를 선택 로드한다. 그 번들은 실제 프로젝트에서 뽑아낸 예시이므로 구조가 다르면 참고용으로만 쓴다.

## Agent 적용 기준

CTO는 트랜잭션, 보안, 데이터 정합성, API 계약 변경을 검토한다.

PL은 패키지 구조, 공통 컴포넌트, 테스트 경계를 정리한다.

PA는 지정된 계층과 파일 범위 안에서만 구현한다.
