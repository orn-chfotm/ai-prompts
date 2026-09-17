---
description: "ApplicationException 계층 구조"
---

# 예외 계층

```
RuntimeException
  └── ApplicationException (abstract, core/exception/)
        ├── NotFoundException       → 404 NOT_FOUND  (리소스 없음)
        ├── BusinessException       → 409 CONFLICT   (중복, 상태 충돌)
        ├── InvalidInputException   → 400 BAD_REQUEST (잘못된 입력)
        └── NotAllowedException     → 403 FORBIDDEN  (권한 없음)
```

도메인별 예외 클래스는 만들지 않는다. 위 4개 공통 타입 중 의미에 맞는 것을 골라, 도메인 `{Domain}ExceptionCode` enum 값과 함께 직접 던진다.

```java
// 조회 실패
xxxRepository.findById(id)
        .orElseThrow(() -> new NotFoundException(XxxExceptionCode.XXX_NOT_FOUND));

// 상태 충돌
throw new BusinessException(XxxExceptionCode.XXX_STATUS_CONFLICT);
```

HTTP status와 메시지는 예외 클래스가 아니라 **enum 값이 결정한다**. 공통 타입은 의미 분류(404/409/400/403)를 코드에서 읽히게 하는 역할만 한다.

## ErrorCode 타입

4개 공통 타입의 생성자는 `ErrorCode` 인터페이스를 받는다. enum은 다른 enum을 상속할 수 없으므로(Java 제약), core `ExceptionCode`와 도메인 `{Domain}ExceptionCode`가 공통 타입을 갖는 방법은 `ErrorCode` 구현뿐이다.

```
ErrorCode (interface)
 ├── core ExceptionCode          (공통/보안 코드)
 └── {Domain}ExceptionCode       (도메인 코드)
```

`GlobalExceptionHandler`가 `ApplicationException` 하나로 4개 타입을 모두 잡아 `FailResponse`로 변환한다. (→ `response/01-envelope.md`)
