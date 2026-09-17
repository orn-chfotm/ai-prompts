---
description: "테스트 전략과 UnitTestHelper 사용 기준"
---

# 테스트 전략

모든 테스트를 `@SpringBootTest`로 작성하지 않는다.
테스트 대상의 범위에 따라 가볍고 명확한 테스트를 우선 선택한다.

## 테스트 유형

### Entity / Value Object
- Spring Context 없이 순수 JUnit으로 테스트한다.
- 상태 변경 메서드, 계산 로직, 검증 로직을 확인한다.
- Repository, Service, MockMvc를 사용하지 않는다.

```java
class ProductTest {

    @Test
    @DisplayName("재고를 차감한다")
    void removeStock() {
        Product product = Product.builder()
                .stockQuantity(10)
                .build();

        product.removeStock(3);

        assertThat(product.getStockQuantity()).isEqualTo(7);
    }
}
```

### Service
- 기본은 Mockito 기반 단위 테스트를 우선한다.
- 트랜잭션, JPA dirty checking, 실제 Repository 연동 확인이 필요한 경우에만 Spring 통합 테스트를 사용한다.
- Service 테스트는 Controller, MockMvc에 의존하지 않는다.

### Repository
- `@DataJpaTest`를 사용한다.
- QueryDSL 동적 조건, 연관관계 조회, 제약조건, custom repository 동작을 검증한다.
- Repository 위치는 `infra/persistence/{domain}` 기준으로 테스트한다.

### Controller
- HTTP request/response, validation, 인증 principal, SuccessResponse envelope을 검증한다.
- 필요한 경우 MockMvc를 사용한다.
- 비즈니스 로직 자체는 Service/Entity 테스트에서 검증한다.

### Integration / Flow
- `@SpringBootTest` + `@AutoConfigureMockMvc`는 주요 사용자 흐름 검증에만 사용한다.
- 회원가입 → 로그인 → 주문 생성처럼 여러 레이어가 함께 동작해야 하는 시나리오에 한정한다.

## UnitTestHelper 사용 기준

`UnitTestHelper`는 이름과 달리 Spring Context를 사용하는 통합 테스트 helper다.
따라서 모든 테스트가 상속하지 않는다.

원 프로젝트 예시에서는 2026-08-19 멀티모듈 전환 이후 `UnitTestHelper`는 앱별로 분리되어 있다 (공유하지 않음).
- `admin-api/src/test/java/.../adminapi/helper/UnitTestHelper.java`: `POST /v1/admin` + `POST /v1/login/admin`으로 `adminAccessToken`을 발급한다.
- `user-api/src/test/java/.../userapi/helper/UnitTestHelper.java`: `POST /v1/user` + `POST /v1/login/user`로 `accessToken`/`refreshToken`을 발급한다.

admin 쓰기 + 조회가 섞여 있던 기존 테스트(`ProductControllerTest`, `ProductOptionControllerTest`, `OptionTemplateControllerTest`)는 컨트롤러 분리에 맞춰 쪼개졌다: 쓰기 시나리오는 `admin-api` 테스트로, 조회 시나리오는 `user-api` 테스트로 이동했고, `user-api` 쪽에서 admin 전용 데이터 셋업이 필요하면 HTTP 호출 대신 `domain`의 Service(`ProductOptionService`, `OptionTemplateService` 등)를 직접 주입받아 호출한다 — `user-api`에는 애초에 admin 로그인/쓰기 엔드포인트 자체가 없기 때문이다.

사용 가능:
- 로그인 토큰이 필요한 MockMvc 통합 테스트
- 여러 API 흐름을 검증하는 `@SpringBootTest` 테스트

사용 금지:
- Entity 단위 테스트
- 값 객체 테스트
- 순수 Service 단위 테스트
- Repository `@DataJpaTest`

## 테스트 DB

- 테스트 리소스는 `src/test/resources/application-test.yml`에 둔다.
- 테스트 profile은 `@ActiveProfiles("test")`를 사용한다.
- 테스트 DB는 독립적으로 초기화되어야 한다.
- 단일 테스트 실행: `./gradlew test --tests "패키지.클래스명.메서드명"`
