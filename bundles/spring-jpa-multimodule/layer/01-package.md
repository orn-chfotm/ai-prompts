---
description: "core / domain / infra / admin-api / user-api Gradle 멀티 모듈 구조"
---

# 모듈 / 패키지 구조

원 프로젝트 예시(2026-08-21 기준)에서는 5개 Gradle 모듈로 구성된다. 관리자 서버(`admin-api`)와 사용자 서버(`user-api`)를 독립적으로 배포하고, `domain`이 `infra`(DB/파일 등 외부 시스템 구현)에 컴파일 타임으로 의존하지 않도록 컴파일러가 계층 경계를 강제하기 위한 구조다.

```
e-commerce/ (root, 소스 없음, 오케스트레이션 전용)
├── core/            → 액터(admin/user)를 전혀 모르는 순수 공용 라이브러리
├── domain/          → 공유 비즈니스 계층: entity, service, dto, exception, Repository 포트(인터페이스)
├── infra/           → Repository 어댑터(QueryDSL 구현체), 파일 저장 어댑터(Local/S3), QueryDSLConfig
├── admin-api/       → 관리자 전용 배포 앱 (controller, security, main class)
└── user-api/        → 사용자 전용 배포 앱 (controller, security, main class)
```

기본 패키지:
- `core` 모듈 → `com.build.ecommerce.core`
- `domain` 모듈 → `com.build.ecommerce.domain`
- `infra` 모듈 → `com.build.ecommerce.infra` (Repository 어댑터, 파일 저장 어댑터, config 전부 이 패키지 트리 안에 있음)
- `admin-api` 모듈 → `com.build.ecommerce.adminapi`
- `user-api` 모듈 → `com.build.ecommerce.userapi`

## 의존 방향

```
admin-api ──► domain ──► core
admin-api ──► infra  ──► domain
user-api  ──► domain ──► core
user-api  ──► infra  ──► domain
```

`domain`은 `infra`를 컴파일 타임에 전혀 모른다 (`domain/build.gradle`에 `infra` 의존성 없음) — 이게 이 구조의 핵심이다. `admin-api`/`user-api`는 `domain`과 `infra`를 각각 직접 의존한다(런타임에 Repository 구현체/파일 저장 어댑터 빈이 필요하므로). `admin-api`와 `user-api`는 서로 의존하지 않는다.

## 설계 기준

DB는 서비스 서버 자체의 내부가 아니라 **외부 시스템**이다. Repository를 "포트(순수 인터페이스)"와 "어댑터(`JpaRepository`+QueryDSL 구현체)"로 나눈다:

- **Repository 인터페이스**는 `domain` 모듈의 `domain/{name}/repository/` 패키지에 둔다 — `extends JpaRepository` 하지 않는 순수 Java 인터페이스다. Service가 실제로 쓰는 메서드만 선언한다.
- **`{Name}JpaRepository`**(`extends JpaRepository<Entity, Long>`, Spring Data 프레임워크 타입)와 **`{Name}RepositoryAdapter`**(도메인 포트 구현체, QueryDSL 커스텀 로직 포함), 파일 저장소 구현체(`LocalFileStorageService`/`S3FileStorageService`), `QueryDSLConfig`는 전부 `infra` 모듈에 둔다.

Entity(`@Entity` 애노테이션이 붙은 클래스)는 계속 `domain`에 있다 — 이 분리는 "Repository 선언(`extends JpaRepository`)"과 "QueryDSL 구현"만 `infra`로 옮기는 것이지, 영속성 모델 자체를 도메인 모델에서 분리하는 게 아니다. Service가 다루는 `Product`, `Order` 등은 여전히 JPA 영속성 컨텍스트가 관리하는 객체이고, dirty-checking도 그대로 동작한다.

자세한 패턴은 `querydsl/01-custom-repo.md` 참조 — 반드시 읽고 따를 것.

`domain`은 비즈니스 정책, entity, service, DTO, 도메인 예외, Repository 포트를 표현한다. `admin-api`/`user-api`는 controller와 각 앱 전용 security 설정만 갖는다.

## 도메인 내부 구조 (domain 모듈)

```
domain/src/main/java/com/build/ecommerce/domain/{name}/
  entity/
  service/
  repository/        ← Repository 포트 (인터페이스만)
  dto/
    request/
    response/
  exception/
  enums/
```

`domain/{name}/controller`는 두지 않는다. Controller는 항상 `admin-api` 또는 `user-api` 모듈에 있다.

## 영속성 구현 구조

```
domain/src/main/java/com/build/ecommerce/domain/{name}/repository/       ← domain 모듈 (포트)
  {Name}Repository.java             순수 인터페이스, extends JpaRepository 없음

infra/src/main/java/com/build/ecommerce/infra/persistence/{name}/        ← infra 모듈 (어댑터)
  {Name}JpaRepository.java          interface extends JpaRepository<Entity, Long> (default 접근제어자)
  {Name}RepositoryAdapter.java      @Repository, {Name}Repository 구현체 (QueryDSL 커스텀 로직 포함)
```

- Service는 생성자 주입으로 `domain/{name}/repository`의 Repository **인터페이스**를 사용한다. `infra`의 구현체 클래스를 직접 import하지 않는다.
- `core/`에 도메인 비즈니스 로직을 두지 않는다.
- 파일 업로드 등 순수 기술 어댑터(엔티티 의존 없음)는 `infra/{concern}/{impl}` 형태로 둔다 (예: `infra/file/local/LocalFileStorageService.java`).

## 새 도메인이 admin/user 중 어디에 속하는지 판단

새 기능을 추가하기 전에 먼저 판단한다.

| 유형 | 예시 | Controller 위치 |
|---|---|---|
| Admin 전용 | 관리자 등록/조회 | `admin-api`만 |
| User 전용 | 배송지, 장바구니, 주문, 찜 | `user-api`만 |
| 공유 (쓰기=Admin, 조회=양쪽) | 상품, 옵션템플릿 | `admin-api`(쓰기+조회) + `user-api`(조회만), 같은 `domain` Service 재사용 |

엔티티/Service/Repository 포트는 판단과 무관하게 항상 `domain` 모듈에 하나만 존재한다. Controller만 필요한 만큼 앱 모듈에 나눠 둔다.

## Security / JWT 모듈 배치

- 액터를 모르는 순수 JWT 검증 로직(`JwtProvider`, `JwtService`, `JwtAuthenticationFilter`/`Provider`/`Token`, `JwtPayload`, `JwtProperty`)은 `core`에 공유로 둔다.
- 로그인 스택(`CustomAdminLoginFilter`/`Provider`/`DetailService`, `CustomUserLoginFilter`/`Provider`/`DetailService`)과 `SecurityFilterConfig`/`SecurityConfig`는 각 앱 모듈(`adminapi.security.login`/`config`, `userapi.security.login`/`config`)에 물리적으로 분리되어 있다. 공용 베이스 클래스로 다시 묶지 않는다 — admin/user security가 향후 더 갈라질 가능성을 열어두기 위한 의도적인 설계다.
- 자세한 내용은 `security/01-jwt.md` 참조.
