---
description: "작업 후 자체 점검 체크리스트"
---

# Review Checklist

기능 추가 또는 수정 후 다음 항목을 확인한다.

## 구조

- 새 Repository가 `infra/persistence/{domain}`에 있는가?
- `domain/{name}/repository` 패키지를 만들지 않았는가?
- DB, 파일, 외부 API 구현이 `infra/`에 있는가?
- 도메인 비즈니스 로직이 `core/`에 들어가지 않았는가?

## Controller / Response

- Controller가 비즈니스 로직을 포함하지 않는가?
- Controller가 Repository를 직접 호출하지 않는가?
- 성공 응답이 `SuccessResponse` factory method를 사용하는가?
- 실패 응답을 직접 만들지 않고 예외로 처리하는가?

## DTO / Entity

- Request DTO는 validation을 포함하는가?
- Entity 또는 값 객체 생성 시 builder를 사용하는가?
- Response DTO는 `@Builder`와 static factory를 사용하는가?
- Entity 상태 변경은 setter가 아니라 의미 있는 메서드로 처리하는가?

## Repository / QueryDSL

- 새 쿼리를 `@Query`(JPQL)로 작성하지 않고 QueryDSL로 작성했는가? (→ `querydsl/01-custom-repo.md`)
- QueryDSL 구현체 이름이 `{Domain}CustomRepositoryImpl`인가?
- QueryDSL 구현체가 `infra/persistence/{domain}`에 있는가?
- 목록 조회가 `Optional<List<T>>` 대신 `List<T>`를 반환하는가?
- null 조건은 BooleanExpression helper에서 처리하는가?

## Security / Config

- 공개 endpoint가 정말 인증 불필요한가?
- local/test 전용 endpoint가 prod에 열리지 않는가?
- secret이 yml에 직접 고정되지 않았는가?
- profile별 설정이 분리되어 있는가?

## Test

- 테스트 유형이 대상 범위에 맞는가?
- Entity 테스트가 Spring Context 없이 동작하는가?
- Repository 테스트는 `@DataJpaTest`로 검증하는가?
- 통합 테스트는 꼭 필요한 주요 흐름에만 사용하는가?
