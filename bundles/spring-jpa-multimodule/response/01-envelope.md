---
description: "SuccessResponse / FailResponse 공통 응답 envelope 사용법"
---

# 응답 Envelope

## SuccessResponse (성공)
```java
// Controller 반환 타입
public ResponseEntity<SuccessResponse<XxxResponse>> getXxx(...) {
    return SuccessResponse.toResponse(service.getXxx(...));
}
```
JSON:
```json
{ "timestamp": "...", "status": 200, "message": "OK", "data": { ... } }
```

## Controller return 규칙
- Controller는 성공 응답만 반환한다.
- 실패 응답은 `GlobalExceptionHandler` / `RestControllerAdvice`에서 처리한다.
- Controller는 `new SuccessResponse(...)` 또는 직접 `ResponseEntity.status(...).body(...)`를 사용하지 않는다.
- 현재 기본 성공 응답은 반드시 `SuccessResponse.toResponse(...)`를 통해 반환한다.
- 생성, 삭제, 페이지 응답처럼 HTTP 상태나 응답 형태가 달라져야 하면 `SuccessResponse`에 factory method를 먼저 추가한 뒤 Controller에서 사용한다.

```java
// 현재 기본 패턴
return SuccessResponse.toResponse(service.getXxx(...));

// 필요 시 SuccessResponse에 factory 추가 후 사용
return SuccessResponse.toCreated(service.createXxx(...));
return SuccessResponse.toNoContent();
return SuccessResponse.toPageResponse(service.searchXxx(...));
```

## FailResponse (실패)
`GlobalExceptionHandler`가 자동 처리. 직접 생성 불필요.

JSON:
```json
{ "timestamp": "...", "status": 404, "code": "NOT_FOUND", "message": "정보를 찾을 수 없습니다." }
```

## Validation 에러
`BindException` → `FailResponse<List<ValidationErrorResponse>>` 자동 변환.
```json
{
  "status": 400,
  "code": "BAD_REQUEST",
  "message": "요청 값을 확인해주세요.",
  "data": [{ "field": "email", "message": "이메일 형식이 올바르지 않습니다." }]
}
```
