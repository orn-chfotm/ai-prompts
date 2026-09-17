---
description: "REST API URI와 Controller 작성 규칙"
---

# API URI 규칙

URI는 리소스 중심으로 작성하고, 행위는 HTTP method로 표현한다.

## 기본 규칙

- API prefix는 `/v1`을 사용한다.
- 리소스명은 복수형을 기본으로 한다.
- URI에 동사를 넣지 않는다.
- 식별자는 `{resourceId}` 형태로 명확히 표현한다.

```text
GET    /v1/products
GET    /v1/products/{productId}
POST   /v1/products
PATCH  /v1/products/{productId}
DELETE /v1/products/{productId}
```

## 피하는 형태

```text
POST /v1/products/{productId}/delete
GET  /v1/getProducts
POST /v1/product/list
```

## 현재 프로젝트 예시

```text
GET    /v1/products
GET    /v1/products/{productId}
POST   /v1/products/{productId}/wishes
DELETE /v1/products/{productId}/wishes
GET    /v1/orders
POST   /v1/orders
GET    /v1/users/me
```

## Controller 규칙

- Controller는 Request DTO를 받고 Response DTO를 반환한다.
- Controller에서 Entity를 직접 생성하지 않는다.
- Controller에서 Repository를 직접 호출하지 않는다.
- 성공 응답은 `SuccessResponse` factory method를 사용한다.
- 실패 응답은 예외를 던지고 `GlobalExceptionHandler`에서 처리한다.
