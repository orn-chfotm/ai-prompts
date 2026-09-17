---
description: "ExceptionCode enum 작성 규칙"
---

# ExceptionCode 패턴

## 공통 코드 (core/exception/code/ExceptionCode.java)

공통 기본값과 보안(인증/인가) 코드만 둔다. 도메인 업무 코드는 두지 않는다.

```java
@Getter
@RequiredArgsConstructor
public enum ExceptionCode implements ErrorCode {
    EXCEPTION(HttpStatus.INTERNAL_SERVER_ERROR, "잠시후 다시 시도해주세요."),
    VALIDATION_EXCEPTION(HttpStatus.BAD_REQUEST, "요청 값을 확인해주세요."),
    NOT_FOUND(HttpStatus.NOT_FOUND, "정보를 찾을 수 없습니다."),
    CONFLICT(HttpStatus.CONFLICT, "요청을 처리할 수 없는 상태입니다.");

    private final HttpStatus httpStatus;
    private final String message;
}
```

## 도메인별 코드 (domain/{name}/exception/code/{Domain}ExceptionCode.java)

각 도메인은 자기 에러 케이스를 **자기 enum**에 정의한다. 도메인 업무 예외는 core 코드를 재사용하지 않고 항상 도메인 enum 값을 만든다 — 메시지가 도메인 맥락을 담아야 하기 때문이다.

```java
@Getter
@RequiredArgsConstructor
public enum ProductExceptionCode implements ErrorCode {

    PRODUCT_NOT_FOUND(HttpStatus.NOT_FOUND, "제품 정보를 찾을 수 없습니다."),
    PRODUCT_NOT_ENOUGH_STOCK(HttpStatus.CONFLICT, "주문 상품의 재고가 부족합니다."),
    FILE_UPLOAD_EXCEED_LIMIT(HttpStatus.BAD_REQUEST, "파일 업로드 최대 개수를 초과했습니다.")
    ;

    private final HttpStatus httpStatus;
    private final String message;
}
```

## 이름 규칙

enum 이름은 `ExceptionCode`가 아니라 `{Domain}ExceptionCode`로 둔다. `OrderService`처럼 한 파일에서 여러 도메인 코드를 쓰는 경우가 많은데, 이름이 전부 `ExceptionCode`면 import가 충돌해 FQN을 써야 한다.

```java
// 한 파일에서 공존 가능
import com.build.ecommerce.domain.order.exception.code.OrderExceptionCode;
import com.build.ecommerce.domain.product.exception.code.ProductExceptionCode;
import com.build.ecommerce.domain.user.exception.code.UserExceptionCode;
```
