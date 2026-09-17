---
description: "@AuthenticationPrincipal 사용 패턴"
---

# 인증 사용자 식별

JWT 검증 후 `JwtPayload.id()`가 `Authentication`의 principal로 설정된다.

## Controller에서 사용자 ID 추출
```java
@GetMapping
public ResponseEntity<SuccessResponse<XxxResponse>> getXxx(
        @AuthenticationPrincipal Long userId) {
    return SuccessResponse.toResponse(service.getXxx(userId));
}
```

- principal 타입은 `Long` (userId).
- `UserDetails`가 아니므로 Spring Security 기본 `@AuthenticationPrincipal`과 다르게 동작.
- Service 메서드는 `userId`를 파라미터로 받아 DB에서 사용자를 조회.

## 권한 제어
```java
@PreAuthorize("hasRole('ADMIN')")   // 관리자 전용
@PreAuthorize("hasRole('USER')")    // 사용자 전용
@PreAuthorize("permitAll()")        // 비인증 허용
```
`SecurityFilterConfig`에 `@EnableMethodSecurity(securedEnabled = true, prePostEnabled = true)` 활성화됨.
