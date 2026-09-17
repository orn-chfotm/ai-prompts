---
description: "Controller / Service / Repository 레이어별 책임 경계"
---

# 레이어 책임

## Controller
- HTTP 요청/응답만 담당. 비즈니스 로직 포함 금지.
- `@Valid`로 유효성 위임, `SuccessResponse` factory method 패턴으로 반환.
- 인증 사용자 식별: `@AuthenticationPrincipal Long userId` (→ `security/02-principal.md`)
- Controller는 `admin-api` 또는 `user-api` 모듈에만 위치한다 (`domain` 모듈에는 controller를 두지 않는다, → `layer/01-package.md`).
- 상품/옵션템플릿처럼 admin 쓰기 + 공개 조회가 섞인 기능은 조회용 GET 엔드포인트를 `admin-api`/`user-api` 양쪽에 각각 두고, 같은 `domain` Service를 재사용한다. 쓰기 엔드포인트는 `admin-api`에만 둔다.

## Service
```java
@Service
@Transactional
@RequiredArgsConstructor
public class XxxService {

    private final XxxRepository xxxRepository;
}
```

- 비즈니스 로직과 트랜잭션 경계 관리.
- 조회 전용 메서드: `@Transactional(readOnly = true)`.
- Entity에 위임 가능한 상태 변경 로직은 Entity 메서드로 위임.
- Repository는 생성자 주입(DI)으로 사용한다.
- Service는 DB에 직접 접근하지 않고 Repository 인터페이스(포트) 메서드를 호출한다.
- Service는 `infra` 모듈의 구현체 클래스를 직접 import하지 않는다 (컴파일 타임에 `domain`은 `infra`를 모른다).

## Repository
- Repository **인터페이스**(포트)는 `domain/{domain}/repository` 아래에 둔다 (`domain` 모듈). `extends JpaRepository`를 쓰지 않는 순수 Java 인터페이스다 — DB 통로(`JpaRepository`)가 domain에 있으면 안 된다는 원칙.
- DB는 웹 서비스 서버 외부 영역이므로, DB와 직접 통신하는 **구현체**(`{Domain}JpaRepository` + `{Domain}RepositoryAdapter`)는 `infra` 모듈의 책임이다.
- 동적 쿼리(QueryDSL)는 `{Domain}RepositoryAdapter` 안에 직접 작성한다. (→ `querydsl/01-custom-repo.md`)

## Entity
- 상태 변경 로직은 Entity 메서드로 캡슐화 (예: `order.cancel()`, `product.removeStock()`).
- 직접 생성자 노출 금지 → `@NoArgsConstructor(access = PROTECTED)` + `@Builder`.
