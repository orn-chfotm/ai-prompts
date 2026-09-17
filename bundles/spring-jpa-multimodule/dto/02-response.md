---
description: "Response DTO 작성 패턴 (Builder + static factory)"
---

# Response DTO 패턴

```java
@Builder
public record XxxResponse(
        Long id,
        String fieldName
) {
    public static XxxResponse toDto(Xxx entity) {
        return XxxResponse.builder()
                .id(entity.getId())
                .fieldName(entity.getFieldName())
                .build();
    }
}
```

## 규칙
- Response DTO는 Java `record`를 기본으로 사용한다.
- Response DTO 생성은 `@Builder`를 사용한다. 필드가 적더라도 응답 필드 추가/변경 시 호출부 가독성을 유지하기 위함이다.
- Entity → DTO 변환은 `static toDto(Entity entity)` 또는 `static toResponse(...)` factory 메서드에 둔다.
- Service에서 변환 후 반환. Controller는 DTO만 받음.
- Controller, Service에서 Response DTO 생성자를 직접 호출하지 않는다. Response DTO의 static factory 또는 builder를 사용한다.
- 상황별 응답 구조가 다른 경우 메서드 오버로딩 또는 의미 있는 factory 이름을 사용한다.

```java
// 예: 목록용 vs 상세용
public static XxxResponse toDto(Xxx entity) { ... }
public static XxxResponse toDetailDto(Xxx entity, List<YyyResponse> details) { ... }
```
