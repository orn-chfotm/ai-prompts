---
description: "Entity 기본 선언 패턴"
---

# Entity 기본 패턴

```java
@Entity
@Table(name = "TABLE_NAME")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Getter
@Comment(value = "테이블 설명", on = "TABLE")
public class Xxx extends BaseTimeEntity {

    @Id @GeneratedValue
    @Column(name = "XXX_ID")
    @Comment("PK")
    private Long id;

    @Column(nullable = false)
    @Comment("필드 설명")
    private String fieldName;

    @Builder
    public Xxx(String fieldName) {
        this.fieldName = fieldName;
    }
}
```

## 규칙
- `BaseTimeEntity` 상속 → `createdAt`, `updatedAt` 자동 관리.
- PK: `@Id @GeneratedValue` (SEQUENCE 전략).
- 컬럼명: 대문자 스네이크 케이스.
- Enum 컬럼: `@Enumerated(EnumType.STRING)`.
- Entity 생성은 `@Builder`를 기본으로 사용한다.
- `@Builder`는 전체 필드 생성자가 아닌 **도메인 의미 있는 생성자**에만 선언한다.
- `id`, audit 필드, 연관관계 컬렉션처럼 외부에서 임의로 주입하면 안 되는 필드는 builder 파라미터에 포함하지 않는다.
- Entity 상태 변경은 setter 대신 의미 있는 메서드로 캡슐화한다.
