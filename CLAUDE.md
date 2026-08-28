# CLAUDE.md — tfmodule-aws-api-gateway

이 문서는 Claude Code가 본 저장소에서 작업할 때 따르는 규칙과 컨텍스트를 정의한다. 구현 세부 로직은 코드가 기준이며, 이 문서는 모듈의 의도와 작업 시 지켜야 할 약속을 이해하는 데 초점을 둔다.

## 1. 프로젝트 개요

- 프로젝트명: `tfmodule-aws-api-gateway`
- 주 언어: Terraform (HCL)
- 기본 브랜치: `main`
- 배포 방식: git 태그(`v1.x.x`)로 배포되는 공유 모듈. 소비 프로젝트가 `?ref=v1.x.x`로 버전을 고정해 참조한다

AWS API Gateway **REST API**를 구성하는 재사용 Terraform 모듈이다. 하나의 API를 "API 본체 → 경로(리소스) 계층 → 메서드/백엔드 통합 → 스테이지 배포 → 커스텀 도메인" 순서로 조립할 수 있도록, 루트 모듈과 네 개의 서브모듈로 역할을 나눴다.

- 루트 모듈: REST API 본체를 만든다. 선택적으로 API Gateway가 CloudWatch에 로그를 쓸 수 있게 하는 계정 수준 설정(IAM 역할 + `aws_api_gateway_account`)도 함께 만든다.
- `resource`: URL 경로 한 단계(`/v1`, `/users`, `/{proxy+}`)를 만든다. 계층은 모듈을 체이닝해 표현한다.
- `method`: 특정 경로에 HTTP 메서드와 백엔드 통합(HTTP, HTTP_PROXY, AWS, AWS_PROXY, MOCK)을 붙인다. 메서드 응답과 통합 응답도 함께 다룬다.
- `stage`: 배포(deployment)와 스테이지를 만들고 액세스 로그, 메서드별 설정(로깅·메트릭·캐시·스로틀링), WAF 연결을 처리한다.
- `domain`: 커스텀 도메인을 만들고 ACM 인증서와 Route53 alias 레코드를 연결한다.

소비자는 `tfmodule-context` 모듈이 만든 `context` 객체를 각 모듈에 주입해 네이밍 접두사(`name_prefix`)와 태그를 표준화한다.

## 2. 기술 스택

| 구분 | 값 |
| --- | --- |
| 언어 | Terraform 100% |
| Terraform 요구 버전 | `>= 1.5.7` (`versions.tf`, 모든 서브모듈 동일) |
| AWS provider | `>= 6.0.0` |
| 로컬 Terraform | v1.5.7 |
| 패키지 매니저 | 해당 없음 |
| CI 시스템 | 미탐지 |
| 문서 도구 | terraform-docs (`README.md` 표, 각 서브모듈의 `HELP.md`) |

## 3. 디렉터리 구조와 모듈 간 관계

| 경로 | 역할 |
| --- | --- |
| `(root)` | REST API 본체, CloudWatch 로깅용 계정 설정(`create_api_account`로 선택), `context` 입력 정의, 하위 모듈로 넘길 `ids` 출력 |
| `resource/` | API 경로 한 단계 생성. 상위의 `ids`를 `parent_ids`로 받아 계층을 이어간다 |
| `method/` | 메서드 + 통합 + (메서드/통합) 응답. CORS preflight용 MOCK+OPTIONS 특수 처리 포함 |
| `stage/` | 배포·스테이지·메서드 설정, 액세스 로그 그룹, WAF Web ACL 연결 |
| `domain/` | REGIONAL/EDGE 커스텀 도메인, ACM 인증서 조회, Route53 A(alias) 레코드 |

모듈을 이어 주는 핵심 인터페이스는 `ids = { rest_api_id, resource_id }` 객체다. 루트 모듈은 REST API의 루트 경로(`/`) ID를, `resource` 모듈은 자신이 만든 경로의 ID를 `ids`로 내보내고, 하위 `resource`·`method` 모듈은 이를 `parent_ids`로 받는다. `stage`와 `domain`은 이 체인에 속하지 않고 `rest_api_id`(stage) 또는 `context`(domain)만 받는다.

이해에 도움이 되는 설계 포인트는 다음과 같다.

- `context` 타입이 모듈마다 다르다. 루트 모듈은 필드가 고정된 object 타입이고, `stage`·`domain`은 `any`다. `domain` 모듈은 루트 object에 없는 `context.domain`을 사용하므로 `any`가 필요하다. 이 차이는 의도된 것이며, 루트 object에 필드를 추가할 때는 `tfmodule-context`가 실제로 제공하는 필드인지 확인한다.
- `create_api_account`는 AWS 계정·리전당 하나만 존재하는 전역 설정을 건드린다. 기본값은 `false`이며, 같은 계정에서 여러 API 모듈 인스턴스 중 하나에서만 켜야 한다. `stage`의 `logging_level`·`metrics_enabled`는 이 설정이 있어야 동작한다.
- `method` 모듈은 별도 지정이 없으면 200 상태의 메서드 응답과 통합 응답을 함께 만든다. 응답을 세밀하게 제어하려면 `status_code`, `response_models`, `response_parameters`, `integration_response_parameters` 등을 조합한다.
- `stage`의 재배포는 `redeployment` 문자열의 해시 변화로 트리거된다. API를 정의한 파일 내용을 넘기는 것이 관례다.
- `domain` 모듈은 다른 모듈과 달리 `create` 변수가 없고, `endpoint_type`에 따라 REGIONAL 또는 EDGE 도메인 중 하나만 만든다. ACM 인증서는 기본 도메인(`domain` 또는 `context.domain`) 이름으로 조회하므로, 서브도메인을 포함하는(와일드카드 등) 발급 완료 인증서가 있어야 한다.

작업 전에 참고할 기존 문서는 다음과 같다.

- `README.md` — 모듈·서브모듈의 사용 예시(HCL)와 루트 모듈의 terraform-docs 표(Requirements/Inputs/Outputs). 루트 변수·출력을 바꾸면 이 표를 함께 갱신한다
- `<submodule>/HELP.md` — terraform-docs로 생성한 서브모듈별 Inputs/Outputs 표. 서브모듈 변수·출력을 바꾸면 해당 `HELP.md`를 함께 갱신한다

## 4. 빌드 · 실행 · 테스트 명령

| 구분 | 명령 | 비고 |
| --- | --- | --- |
| 문법 검증 | `terraform init -backend=false && terraform validate` | 루트와 각 서브모듈 디렉터리에서 각각 실행한다. 변경한 모듈은 반드시 통과시킨다 |
| 포맷 검사 | `terraform fmt -check -recursive` | 저장소 전체가 fmt 준수 상태다. 커밋 전 반드시 통과시킨다 |
| plan | `terraform plan` | 이 저장소 단독으로는 실행 불가(`api_name`, `context` 등 필수 입력 없음). 모듈을 소비하는 프로젝트에서 실행한다 |
| 테스트 | `terraform test` | 현재 테스트 파일(`*.tftest.hcl`)이 없다. 실행 요건은 7장 참고 |

## 5. 코드 컨벤션

- 주 언어(Terraform)의 기존 스타일을 우선 따른다. 새로운 스타일을 도입하지 않는다.
- 소스 코드, 주석, 변수·출력 명칭과 description은 영문으로 작성한다.
- 마크다운 문서는 한글로 작성하며, 표 앞에는 반드시 한 줄을 띄운다.
- 수정 전 대상 파일과 호출부를 먼저 읽고, 기존 패턴과 일치하는 방식으로 구현한다.

저장소에서 실제 사용 중인 패턴은 다음과 같다.

- 조건부 생성: 리소스 생성 여부는 `create` 변수(또는 이를 조합한 local)를 `count`로 사용해 제어한다. 새 리소스도 같은 방식을 따른다. 예외적으로 `domain` 모듈은 `endpoint_type`으로 생성 대상을 고른다.
- 출력 안전 참조: count 기반 리소스를 output에서 참조할 때는 리소스가 생성되지 않은 경우를 위해 `try(..., "")` 폴백을 둔다. 같은 생성 조건을 공유하는 리소스 사이에서는 `[0]` 직접 참조를 사용한다. legacy 패턴(`concat(splat)[0]`, `one()`)은 사용하지 않는다.
- 네이밍: 리소스 이름은 `context.name_prefix`를 기반으로 조합한다(API 이름 `<name_prefix>-<api_name>-api`, 로그 그룹 `/apigateway/<name_prefix>-<api_name>-api`, 로깅 역할 `<project>APIGatewayLoggingRole`).
- 태깅: 태그를 지원하는 모든 리소스는 `context.tags`에 `Name` 태그를 합쳐 부여한다.
- 모듈 체이닝: 서브모듈은 `parent_ids = { rest_api_id, resource_id }` 객체를 입력으로 받는다. 이 인터페이스를 바꾸면 README 예시와 모든 소비 프로젝트가 영향을 받는다.
- 변수 선언: `type`과 `description`을 반드시 함께 작성한다. 선택 변수는 보통 `default = null`을 쓰되, 빈 값이 의미를 갖는 경우 `""`, `{}`, `[]`를 기본값으로 둔 변수도 있다. 기존 변수의 기본값을 바꾸는 것은 동작 변경이므로 브레이킹 체인지로 다룬다.
- 허용값이 정해진 변수(`endpoint_type`, `type`, `authorization` 등)는 `validation` 블록으로 검증한다. 선택 변수의 검증은 `coalesce(var.x, <기본값>)`으로 null을 통과시킨다.
- 하위 호환: 이 모듈은 git 태그로 배포되는 공유 모듈이다. 변수 삭제·이름 변경·기본값 변경 등 브레이킹 체인지는 사용자에게 먼저 알리고 진행하며, README의 `?ref=` 버전 예시는 릴리스 시 함께 올린다.

## 6. 필수 작업 지침

이 블록은 프로젝트 종류와 무관하게 항상 동일하게 포함된다. 내용을 임의로 수정하거나 축약하지 않는다.

#### 1. 언어 및 문서 규칙

- 소스 코드, 주석, 변수 정의는 영문으로 작성한다.
- 마크다운 문서는 한글로 작성한다.
- 마크다운 문서의 표 형식은 반드시 한 줄을 띄우고 추가한다.

#### 2. 코드 변경 원칙

- 기존 코드를 먼저 읽는다.
- 작업과 명시적으로 관련된 코드 및 파일만 리팩터링한다. 요청 없이 인접한 함수나 파일을 리팩터링하지 않는다.
- 불필요한 리팩터링을 하지 않는다.
- 사용자의 명시적인 확인 없이 새로운 라이브러리, 패키지를 추가하지 않는다.

#### 3. 보안 원칙

- 소스 코드에 크리덴셜 키 유출, 권한 검증 누락, 데이터 노출을 금지한다.

#### 4. 테스트 원칙

- 모듈 단위의 기능 구현을 추가하면 Mock 테스트를 작성하고 통과시킨다.
- 버그를 수정할 때는 먼저 실패하는 회귀 테스트를 작성한 다음, 수정 사항을 구현하여 통과시킨다.
- 단위 또는 통합 테스트에서 실제 네트워크 및 외부 API 호출을 금지한다.

#### 5. 운영 안전 원칙

- REAL(운영) 환경을 대상으로 하는 파괴적 작업을 금지한다.
- 파괴적인 git 명령의 자동 실행을 금지한다. (`git push --force`, `git reset --hard`, `git clean` 등)

## 7. 테스트 정책

현재 테스트 자산 현황은 다음과 같다.

| 항목 | 값 |
| --- | --- |
| 테스트 파일 수 | 0 (`*.tftest.hcl` 없음) |
| 테스트 명령 | `terraform test` |
| 최소 검증 | 변경한 모듈에서 `terraform init -backend=false && terraform validate` 통과 |

Terraform 모듈의 Mock 테스트는 `terraform test`의 `mock_provider` 블록을 사용한 `.tftest.hcl` 파일로 작성한다. 단, 이 기능에는 버전 제약이 있다.

- `.tftest.hcl` 테스트 프레임워크는 Terraform 1.6 이상, `mock_provider`는 1.7 이상에서 동작한다.
- 이 저장소의 `required_version`(`>= 1.5.7`)과 로컬 Terraform(v1.5.7)은 이 요건을 충족하지 않는다. 따라서 6장의 Mock 테스트 원칙을 적용하려면 로컬 Terraform 업그레이드가 선행되어야 하며, `required_version`을 올리는 것은 소비 프로젝트에 영향을 주는 브레이킹 체인지이므로 사용자 확인 후 진행한다.
- 테스트 도입이 가능해지기 전까지는 `terraform validate`와 `terraform fmt -check`를 최소 검증으로 삼고, 테스트를 작성할 수 없었다는 사실을 작업 결과에 명시한다.

테스트 작성 규칙은 다음과 같다.

- 모듈 단위 기능을 추가하면 Mock 기반 단위 테스트를 함께 작성하고 통과시킨다.
- 버그 수정은 실패하는 회귀 테스트를 먼저 작성한 뒤 수정 사항을 구현한다.
- 단위 및 통합 테스트에서 실제 네트워크와 외부 API를 호출하지 않는다. 외부 의존성은 Mock 또는 Fake로 대체한다.
- 테스트는 실행 순서에 의존하지 않으며, 임시 디렉터리 등 격리된 자원만 사용한다.

## 8. 보안 정책

- 크리덴셜, 액세스 키, 토큰, 비밀번호를 소스 코드와 문서에 하드코딩하지 않는다. 환경 변수 또는 시크릿 저장소를 사용한다.
- 신규 엔드포인트와 핸들러는 인증·인가 검증을 반드시 포함한다. 권한 검증 누락을 금지한다.
- 로그, 에러 응답, 디버그 출력에 개인정보와 내부 식별자를 노출하지 않는다.
- 커밋 전에 시크릿 패턴 스캔을 수행한다.

이 저장소는 재사용 Terraform 모듈로, 자체 시크릿·환경 변수·provider 자격 증명을 보유하지 않는다. AWS 자격 증명은 이 모듈을 소비하는 프로젝트의 provider 구성에서 주입되며, ARN·계정 ID·인증서 등 환경 의존 값은 변수 또는 `data` 소스로만 참조한다. 문서와 예시 코드에는 실제 계정 ID, ARN, 도메인 등 내부 식별 값을 하드코딩하지 않고 `mycompany.com` 같은 예시 값을 사용한다.

API Gateway 관점의 보안 고려 사항은 다음과 같다.

- `method` 모듈의 `authorization` 기본값은 `NONE`이다. 인증이 필요한 엔드포인트 예시나 기본 설정을 추가할 때는 `AWS_IAM`, `CUSTOM`(+`authorizer_id`), `COGNITO_USER_POOLS`(+`authorizer_id`, `authorization_scopes`) 또는 `api_key_required`를 명시하도록 안내한다.
- `stage`의 `data_trace_enabled`는 요청·응답 본문을 CloudWatch에 기록한다. 운영 환경 예시에서는 기본값(`false`)을 유지한다.

## 9. Git 작업 규칙

| 항목 | 값 |
| --- | --- |
| 원격 저장소 | GitHub `oniops/tfmodule-aws-api-gateway` |
| 브랜치 형식 | `feature/<Jira 티켓 ID>` (예: `feature/OI-1199`) |
| 커밋 제목 형식 | `<Jira 티켓 ID> IaC - <한글 설명>` (예: `OI-1199 IaC - AWS Provider 6.x 기준 모듈 리팩토링`) |
| 머지 방식 | PR을 통해 `main`에 머지 |
| 릴리스 | `v1.x.x` git 태그 |

- 커밋 제목의 티켓 ID는 브랜치명에서 가져온다. 과거에는 `DEVT-xxxx - 설명` 형식도 사용했으나 현재 관례는 위 형식이다.
- 릴리스 태그를 올리면 README의 사용 예시(`?ref=v1.x.x`)도 함께 갱신한다.

금지되는 git 동작은 다음과 같다.

- `git push --force`, `git reset --hard`, `git clean` 등 파괴적 명령의 자동 실행을 금지한다.
- 사용자가 명시적으로 요청한 경우에만, 영향 범위를 설명한 뒤 실행한다.
- 커밋과 푸시는 사용자의 요청이 있을 때만 수행한다.

## 10. 금지 사항 요약

다음 항목은 예외 없이 금지한다.

| 구분 | 금지 내용 |
| --- | --- |
| 코드 | 크리덴셜 하드코딩, 권한 검증 누락, 데이터 노출 |
| 변경 범위 | 요청 범위 밖 파일·함수 리팩터링, 불필요한 리팩터링 |
| 의존성 | 사용자 확인 없는 라이브러리·패키지 추가 |
| 호환성 | 사용자 확인 없는 변수 삭제·이름 변경·기본값 변경, `parent_ids` 인터페이스 변경, `required_version` 상향 |
| 테스트 | 실제 네트워크·외부 API 호출 |
| 운영 | REAL 환경 대상 파괴적 작업 |
| Git | 파괴적 git 명령의 자동 실행 |
