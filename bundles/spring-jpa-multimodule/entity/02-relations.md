---
description: "연관관계 매핑 패턴 (ManyToOne, OneToMany, Embedded)"
---

# 연관관계 패턴

## @ManyToOne (N쪽)
```java
@ManyToOne(fetch = FetchType.LAZY)
@JoinColumn(name = "USER_ID", nullable = false)
private User user;
```
- `FetchType.LAZY` 필수. EAGER 사용 금지.

## @OneToMany (1쪽)
```java
@OneToMany(mappedBy = "order", cascade = CascadeType.PERSIST, orphanRemoval = true)
private List<OrderProduct> orderProducts = new ArrayList<>();
```
- 연관관계 편의 메서드는 1쪽(부모) Entity에 작성.
```java
public void addOrderProduct(OrderProduct orderProduct) {
    orderProducts.add(orderProduct);
    orderProduct.setOrder(this);
}
```

## @Embedded (값 객체)
```java
@Embedded
@Column(nullable = false)
private AddressInfo addressInfo;
```
- 값 객체는 `@Embeddable`로 선언.
- 주문 시 배송지처럼 **스냅샷이 필요한 데이터**는 Embedded로 복사해 저장.
