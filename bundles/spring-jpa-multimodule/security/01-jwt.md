---
description: "JWT 인증 필터 체인과 공개 경로 운영 기준"
---

# JWT 인증 흐름

원 프로젝트 예시 기준(2026-08-19 멀티모듈 전환 이후), `admin-api`와 `user-api`는 각각 독립된 `SecurityFilterConfig`/`SecurityConfig`를 가진다 (공유하지 않음). `admin-api`의 필터 체인에는 `CustomAdminLoginFilter`만, `user-api`의 필터 체인에는 `CustomUserLoginFilter`만 등록된다. `JwtAuthenticationFilter`/`Provider`/`Token`은 액터를 모르는 순수 로직이라 `core`에 공유로 남아 양쪽에서 동일하게 동작한다.

## 필터 실행 순서

**admin-api**:
```
요청
 └── JwtAuthenticationFilter       → Authorization 헤더에서 Bearer 토큰 추출 → JwtAuthenticationProvider
 └── CustomAdminLoginFilter        → POST /v1/login/admin → CustomAdminLoginProvider
```

**user-api**:
```
요청
 └── JwtAuthenticationFilter       → Authorization 헤더에서 Bearer 토큰 추출 → JwtAuthenticationProvider
 └── CustomUserLoginFilter         → POST /v1/login/user  → CustomUserLoginProvider
```

## 로그인 엔드포인트
| 경로 | 대상 | 발급 토큰 |
|---|---|---|
| `POST /v1/login/user` | 일반 사용자 | AccessToken + RefreshToken |
| `POST /v1/login/admin` | 관리자 | AccessToken만 |

## 토큰 갱신
`POST /client` + `{ "refreshToken": "..." }` → 새 AccessToken + RefreshToken 발급.
관리자는 RefreshToken 발급 없음.

## 공개 경로 기준

공개 경로는 profile별로 다르게 관리한다.
새 도메인 추가 시 인증이 필요 없는 endpoint만 `SecurityFilterConfig`에 명시적으로 추가한다.

### 모든 환경에서 공개 가능

`admin-api`: `POST /v1/admin`, `POST /v1/login/admin`, `POST /client`
`user-api`: `POST /v1/user`, `POST /v1/login/user`, `POST /client`

`POST /client`(토큰 리프레시)는 양쪽 앱 모두 permitAll에 포함해야 한다 — 이걸 빠뜨리면 AccessToken이 만료된 뒤에는 리프레시 자체가 막히는 문제가 생긴다(과거 단일 모듈 시절 실제로 있었던 버그, 멀티모듈 전환 시 수정됨).

### local/test에서만 공개 가능
```
/h2-console/**
/swagger-ui/**
/v3/**
```

### prod에서 공개 금지 또는 별도 제한
```
POST /v1/admin
/h2-console/**
/swagger-ui/**
/v3/**
```

## 관리자 생성 정책

운영 환경에서 관리자 등록 API를 공개하지 않는다.
관리자 계정 생성은 다음 중 하나로 제한한다.

- 초기 seed data
- DB migration
- 내부망/VPN/IP allowlist로 보호된 endpoint
- 수동 생성 절차

## 토큰 검증 규칙

- API 인증에는 AccessToken만 허용한다.
- RefreshToken은 토큰 갱신 endpoint에서만 사용한다.
- 인증 실패와 권한 실패는 `GlobalExceptionHandler` 또는 security handler를 통해 공통 실패 응답으로 변환한다.
