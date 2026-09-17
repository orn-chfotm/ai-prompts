---
description: "Spring profile과 운영 설정 분리 규칙"
---

# Profile / Config 규칙

환경별 설정은 profile로 분리한다.
운영 비밀값은 repository에 고정하지 않는다.

## 파일 구조

원 프로젝트 예시 기준(2026-08-19 멀티모듈 전환 이후), `admin-api`/`user-api`는 각각 독립된 배포 앱이라 각자 자기 `application*.yml` 세트를 가진다 (공유하지 않음).

```text
admin-api/src/main/resources/
  application.yml          (spring.application.name: ecommerce-admin, server.port: 8081)
  application-prod.yml
admin-api/src/test/resources/
  application-test.yml

user-api/src/main/resources/
  application.yml          (spring.application.name: ecommerce-user, server.port: 8080)
  application-prod.yml
user-api/src/test/resources/
  application-test.yml
```

`core`/`domain` 모듈은 배포 앱이 아니므로 `application.yml`을 갖지 않는다.

두 앱을 로컬에서 동시에 띄우려면 `server.port`가 겹치지 않아야 한다. 각 앱은 독립된 in-memory H2 인스턴스를 쓰므로, 로컬 개발에서는 admin-api에서 만든 데이터가 user-api에는 보이지 않는다(실제 배포에서는 하나의 DB를 공유하도록 datasource를 맞춰야 한다).

## application.yml

공통 설정만 둔다.
환경마다 달라지는 DB URL, secret, logging level, ddl-auto 값은 두지 않는다.

## application-local.yml

local 개발 편의 설정을 둔다.

- H2 사용 가능
- h2-console 허용 가능
- swagger 허용 가능
- 상세 SQL log 허용 가능
- `ddl-auto: create` 또는 `update`는 local에서만 허용

## application-test.yml

테스트 전용 설정을 둔다.

- 테스트 DB 사용
- 테스트마다 독립적으로 초기화 가능해야 함
- `ddl-auto: create-drop` 또는 명확한 test migration 사용
- 운영 secret을 참조하지 않음

## application-prod.yml

운영 설정은 보수적으로 둔다.

- `ddl-auto: validate`
- h2-console 비활성화
- swagger 비공개 또는 인증/망 제한
- SQL 상세 log 비활성화
- DB migration은 별도 배포 단계에서 수행

## Secret 규칙

다음 값은 yml에 직접 고정하지 않는다.

- JWT secret
- DB password
- cloud access key
- 외부 API key
- admin 초기 password

환경변수, secret manager, CI/CD secret을 통해 주입한다.
