---
description: "도메인 예외 사용 패턴"
---

# 도메인 예외 패턴

도메인마다 예외 **클래스**를 만들지 않는다. `{Domain}ExceptionCode` enum에 값을 추가하고, core의 공통 예외 타입으로 던진다.

## 1. enum 값 추가

```java
// domain/{name}/exception/code/{Domain}ExceptionCode.java
public enum XxxExceptionCode implements ErrorCode {

    XXX_NOT_FOUND(HttpStatus.NOT_FOUND, "XXX 정보를 찾을 수 없습니다."),
    XXX_STATUS_CONFLICT(HttpStatus.CONFLICT, "변경 불가능 상태입니다.")
    ;

    private final HttpStatus httpStatus;
    private final String message;
}
```

## 2. 공통 타입으로 throw

| 상황 | 공통 타입 | HTTP |
|---|---|---|
| 리소스 없음 | `NotFoundException` | 404 |
| 중복·상태 충돌 | `BusinessException` | 409 |
| 잘못된 입력 | `InvalidInputException` | 400 |
| 권한 없음 | `NotAllowedException` | 403 |

```java
// Service 조회
Xxx findXxx = xxxRepository.findById(id)
        .orElseThrow(() -> new NotFoundException(XxxExceptionCode.XXX_NOT_FOUND));

// Entity 상태 검증
public void cancel() {
    if (!isCancelable()) {
        throw new BusinessException(XxxExceptionCode.XXX_STATUS_CONFLICT);
    }
    this.status = StatusType.CANCEL;
}
```

메시지가 상황마다 달라져야 하는 입력 검증은 `InvalidInputException(String message)`를 그대로 쓴다.

```java
throw new InvalidInputException("옵션이 등록된 상품은 옵션 조합을 선택해야 합니다.");
```
