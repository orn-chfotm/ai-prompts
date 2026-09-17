---
description: "Repository 포트(domain, 순수 인터페이스)/어댑터(infra, JpaRepository+QueryDSL) 패턴"
---

# Repository 패턴 — 포트(domain) / 어댑터(infra)

원 프로젝트 예시에서는 2026-08-21부로 domain의 Repository 인터페이스는 **`JpaRepository`를 extends하지 않는다.** Repository는 "DB와 app을 연결하는 통로"이므로 그 통로의 실체(Spring Data JPA 프레임워크 타입)가 domain(app의 핵심 영역)에 있으면 안 된다는 판단에 따른 것이다. `domain`은 순수 Java 인터페이스만 갖고, 그 인터페이스를 구현하는 `infra`의 어댑터가 실제 Spring Data JPA/QueryDSL과 통신한다.

**Entity 자체는 그대로 `domain`에 있다.** 이 분리는 Entity를 옮기는 게 아니라, "Repository 선언(`extends JpaRepository`)"과 "QueryDSL 구현"만 `infra`로 옮기는 것이다. 그래서 Service가 받는 `Product`, `Order` 등은 지금처럼 JPA 영속성 컨텍스트가 관리하는 객체 그대로이고, dirty-checking도 그대로 동작한다.

## 구조

```
domain/src/main/java/com/build/ecommerce/domain/{name}/repository/
  {Name}Repository.java        ← 포트. 순수 인터페이스, extends JpaRepository 없음.
                                   Service가 실제로 쓰는 메서드만 선언 (save, findById, 커스텀 쿼리 등)

infra/src/main/java/com/build/ecommerce/infra/persistence/{name}/
  {Name}JpaRepository.java     ← Spring Data가 자동 구현. interface {Name}JpaRepository extends JpaRepository<{Entity}, Long>
                                   (derived query는 여기 선언)
  {Name}RepositoryAdapter.java ← @Repository 빈. {Name}Repository(포트) 구현체.
                                   단순 CRUD/derived query는 {Name}JpaRepository에 위임,
                                   커스텀 로직은 JPAQueryFactory로 여기서 직접 작성.
```

**과거 패턴(더 이상 쓰지 않음)**: `{Name}Repository extends JpaRepository<E,ID>, {Name}CustomRepository` + `{Name}CustomRepositoryImpl`(Spring Data의 fragment 자동 조립 메커니즘). 이 메커니즘 자체가 domain이 `JpaRepository`를 extends해야만 성립하므로 폐기했다. 부수 효과로, 예전에 있던 "fragment 인터페이스와 구현체 패키지 이름이 같아야 한다"는 제약도 **더 이상 해당 없음** — 이제는 평범한 Spring 빈 주입(타입 기준 DI)이라 패키지 위치가 자유롭다.

## 예시

```java
// domain/src/main/java/com/build/ecommerce/domain/product/repository/ProductRepository.java
package com.build.ecommerce.domain.product.repository;

public interface ProductRepository {
    Product save(Product product);
    Optional<Product> findById(Long id);
    Page<Product> searchProducts(ProductSearchRequest searchRequest, Pageable pageable);
    Optional<Product> findByIdForUpdate(Long id);
}
```

```java
// infra/src/main/java/com/build/ecommerce/infra/persistence/product/ProductJpaRepository.java
package com.build.ecommerce.infra.persistence.product;

interface ProductJpaRepository extends JpaRepository<Product, Long> {
}
```

```java
// infra/src/main/java/com/build/ecommerce/infra/persistence/product/ProductRepositoryAdapter.java
package com.build.ecommerce.infra.persistence.product;

@Repository
@RequiredArgsConstructor
class ProductRepositoryAdapter implements ProductRepository {

    private final ProductJpaRepository jpaRepository;
    private final JPAQueryFactory jpaQueryFactory;

    @Override
    public Product save(Product product) {
        return jpaRepository.save(product);
    }

    @Override
    public Optional<Product> findById(Long id) {
        return jpaRepository.findById(id);
    }

    @Override
    public Page<Product> searchProducts(ProductSearchRequest searchRequest, Pageable pageable) {
        List<Product> content = jpaQueryFactory.selectFrom(product)
                .where(
                        fieldEq(searchRequest.field()),
                        nameContains(searchRequest.name())
                )
                .offset(pageable.getOffset())
                .limit(pageable.getPageSize())
                .fetch();
        // countQuery 생략, 실제로는 PageableExecutionUtils.getPage(...)로 조립
        return new PageImpl<>(content, pageable, content.size());
    }

    @Override
    public Optional<Product> findByIdForUpdate(Long id) {
        return Optional.ofNullable(
                jpaQueryFactory.selectFrom(product)
                        .where(product.id.eq(id))
                        .setLockMode(LockModeType.PESSIMISTIC_WRITE)
                        .fetchOne()
        );
    }

    private BooleanExpression fieldEq(String field) {
        return field == null ? null : product.field.eq(field);
    }
}
```

Service는 `ProductRepository`(도메인 포트)를 생성자 주입받아 `save`/`findById`/`searchProducts`/`findByIdForUpdate`를 호출한다 — `infra`의 구현체 클래스를 직접 참조하지 않는다.

## 규칙

- domain의 Repository 인터페이스는 `extends JpaRepository` 하지 않는다. Service가 실제로 쓰는 메서드만 명시적으로 선언한다(`save`, `findById`, `delete`, `flush` 등 기본 CRUD도 필요한 것만 선언 — `JpaRepository`처럼 전체 API 표면을 상속받지 않는다).
- `{Name}JpaRepository`(Spring Data 인터페이스)는 `infra`에 두고, `default`(package-private) 접근제어자로 충분하다 — `{Name}RepositoryAdapter`만 이걸 참조하면 되므로 `public`으로 열지 않는다.
- `{Name}RepositoryAdapter`는 `@Repository` + `package-private class`로 선언한다(외부에서 구현체 타입을 직접 참조할 이유가 없음, Service는 인터페이스 타입으로만 주입받음).
- 커스텀 QueryDSL 로직(fetch join, 동적 조건, 락, 벌크 update/delete)은 `{Name}RepositoryAdapter` 안에 직접 작성한다. 기존 QueryDSL 규칙의 "JPQL 대신 QueryDSL 우선" 원칙(fetch join 체이닝, `setLockMode`로 비관적 락, `.where(...).execute()`로 벌크 삭제/수정)은 그대로 유지된다 — 위치만 Adapter로 바뀌었다.
- Spring Data의 **메서드 이름 기반 derived query**(`findByEmail`, `existsByEmail` 등)와 `@EntityGraph`는 `{Name}JpaRepository`에 선언하고, Adapter가 단순 위임한다.
- 목록 조회는 `Optional<List<T>>` 대신 `List<T>`를 반환한다. 결과가 없으면 빈 리스트를 반환한다.
- 조건이 없는 검색 필드는 `BooleanExpression` helper에서 `null`을 반환해 QueryDSL where에서 제외한다.

## `@EnableJpaRepositories`/`@EntityScan`

```java
@EntityScan(basePackages = "com.build.ecommerce.domain")           // Entity는 domain에 그대로
@EnableJpaRepositories(basePackages = "com.build.ecommerce.infra") // JpaRepository 확장 인터페이스는 전부 infra에만 있음
```

## Q타입 생성
```bash
./gradlew :domain:compileJava
```
생성 위치: `domain/src/main/generated/` (`.gitignore` 대상, `clean` 시 삭제). Entity가 domain에 있으므로 Q-type도 domain에서 생성된다. `infra`는 Q-type을 생성하지 않고(annotationProcessor 없음) domain이 생성한 것을 소비만 한다.
정적 import: `import static com.build.ecommerce.domain.xxx.entity.QXxx.xxx;`
