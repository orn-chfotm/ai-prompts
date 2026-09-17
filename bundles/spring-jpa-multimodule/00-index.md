---
description: "Spring Boot 3 + JPA + QueryDSL + Gradle 멀티모듈 스택의 상세 코드 규칙 번들 진입점입니다."
---

# Spring / JPA / QueryDSL 멀티모듈 번들

이 번들은 아래 스택을 쓰는 프로젝트를 위한 상세 코드 규칙 묶음이다.

- Spring Boot 3 (Java)
- JPA (Hibernate) + QueryDSL
- Gradle 멀티 모듈, `core` / `domain` / `infra` / `app`(배포 앱) 형태의 포트-어댑터 분리
- Spring Security + JWT 인증

`docs/`가 tool과 스택에 중립적인 공통 원칙을 담는다면, 이 번들은 그 원칙을 특정 스택에서 어떻게 구현했는지를 담는다. 모든 프로젝트가 로드하지 않고, 위 스택을 쓰는 프로젝트만 선택적으로 로드한다.

## 경고 — 이 번들은 예시/참고용이다

이 문서들은 **실제 운영 중인 Spring Boot 이커머스 프로젝트에서 그대로 뽑아낸 규칙**이다. 추상화하지 않고 원문을 유지했기 때문에, 원 프로젝트의 고유한 결정이 본문에 그대로 남아 있다.

**프로젝트 구조가 다르면 그대로 적용하지 말고 참고만 한다.** 특히 다음 값은 원 프로젝트 고유값이므로 각자 프로젝트에 맞게 바꿔서 읽어야 한다.

| 항목 | 이 번들의 값 (원 프로젝트) | 각자 프로젝트에서 |
|---|---|---|
| 모듈명 | `core` / `domain` / `infra` / `admin-api` / `user-api` | 자기 모듈 구성으로 대체 |
| 기본 패키지 | `com.build.ecommerce.*` | 자기 base package로 대체 |
| 도메인 예시 | `product`, `order`, `cart`, `wish` 등 | 자기 도메인으로 대체 |
| 앱 분리 축 | 관리자 서버 / 사용자 서버 2개 앱 | 앱이 하나면 분리 축 자체가 없음 |
| 본문의 날짜 | 원 프로젝트의 마이그레이션 시점 기록 | 무시해도 되는 배경 정보 |

단일 모듈 프로젝트, admin/user 분리가 없는 프로젝트, QueryDSL을 쓰지 않는 프로젝트라면 해당 문서는 건너뛰거나 구조 부분만 바꿔서 참고한다.

## 읽는 순서

### 1. 구조 — 먼저 읽는다

모듈 경계와 레이어 책임을 모르면 나머지 문서의 파일 위치 지시가 해석되지 않는다.

@layer/01-package.md
@layer/02-responsibility.md

### 2. API 계약

@api/01-uri.md
@response/01-envelope.md

### 3. 영속성 — Entity와 Repository

@entity/01-base.md
@entity/02-relations.md
@querydsl/01-custom-repo.md

### 4. DTO

@dto/01-request.md
@dto/02-response.md

### 5. 예외 처리

@exception/01-hierarchy.md
@exception/02-code.md
@exception/03-domain.md

### 6. 보안 / 설정

@security/01-jwt.md
@security/02-principal.md
@config/01-profile.md

### 7. 트랜잭션 / 테스트 / 리뷰

@transaction/01-concurrency.md
@testing/01-helper.md
@review/01-checklist.md

## 프로젝트에 연결하는 방법

이 번들을 쓰는 프로젝트의 루트 `CLAUDE.md`에 코어 하네스 아래로 한 줄을 추가한다.

```md
@.ai-prompts/CLAUDE.md                                   ← 코어 (필수)
@.ai-prompts/bundles/spring-jpa-multimodule/00-index.md  ← 이 번들 (선택)
```

`.ai-prompts`는 하네스 submodule 경로 예시다. 실제 경로로 바꿔서 쓴다.

번들은 선택 로드 대상이므로, 스택이 맞지 않는 프로젝트는 이 줄을 추가하지 않는다.
