---
description: "Request DTO 작성 패턴 (Java record + Bean Validation + 변환 메서드)"
---

# Request DTO 패턴

```java
public record XxxRequest(
        @NotBlank String fieldName,
        @NotNull @Positive Long quantity
) {
    public Xxx toEntity() {
        return Xxx.builder()
                .fieldName(fieldName)
                .quantity(quantity)
                .build();
    }
}
```

## 규칙
- Java `record` 사용. 불변 객체.
- Bean Validation 어노테이션 필드에 직접 선언.
- Controller에서 `@Valid @RequestBody XxxRequest request`로 수신.
- Request DTO에서 Entity 또는 값 객체로 변환할 때는 `toEntity()`, `toValueObject()` 같은 명확한 변환 메서드를 둔다.
- Entity 또는 값 객체 생성 시 직접 생성자 호출보다 `builder()`를 우선 사용한다.
- Request DTO 자체에 Lombok `@Builder`는 기본 사용하지 않는다. 테스트 데이터 생성 등 명확한 이점이 있을 때만 예외적으로 사용한다.
- Enum 필드가 필요한 경우 커스텀 Jackson Deserializer 작성 (예: `AddressTypeDeserializer`).

## Enum 역직렬화
```java
public class XxxTypeDeserializer extends JsonDeserializer<XxxType> {
    @Override
    public XxxType deserialize(JsonParser p, DeserializationContext ctx) throws IOException {
        return XxxType.from(p.getText());
    }
}
```
