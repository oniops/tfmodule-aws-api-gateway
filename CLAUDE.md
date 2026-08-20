# CLAUDE.md — tfmodule-aws-api-gateway

이 문서는 Claude Code가 본 저장소에서 작업할 때 따르는 규칙과 컨텍스트를 정의한다. `TODO` 표시는 저장소를 직접 읽고 사람이 확정한다.

## 1. 프로젝트 개요

- 프로젝트명: `tfmodule-aws-api-gateway`
- 주 언어: Terraform
- 탐지된 스택: terraform
- 추적 파일 수: 24개
- 기본 브랜치: `main` (현재 작업 브랜치: `feature/OI-1199`)

AWS API Gateway REST API를 구성하는 재사용 Terraform 모듈이다. 루트 모듈이 REST API(`aws_api_gateway_rest_api`)와 CloudWatch 로깅용 IAM 역할·API Gateway Account를 만들고, 서브모듈(`resource`, `method`, `stage`, `domain`)을 조합해 리소스 계층 → 메서드/통합 → 스테이지 배포 → 커스텀 도메인까지 구성한다. 소비자는 `tfmodule-context` 모듈이 만든 `context` 객체를 주입해 네이밍 접두사와 태그를 표준화하며, git 태그(`v1.x.x`)로 버전을 참조해 사용한다.

## 2. 기술 스택

언어 구성은 다음과 같다.

| 언어 | 파일 수 | 비중 |
| --- | --- | --- |
| Terraform | 22 | 100.0% |

CI/CD 및 도구 체인은 다음과 같다.

| 구분 | 값 |
| --- | --- |
| 빌드 스택 | terraform |
| 패키지 매니저 | 해당 없음 |
| CI 시스템 | 미탐지 |

## 3. 디렉터리 구조

최상위 디렉터리별 파일 분포는 다음과 같다.

| 경로 | 파일 수 | 역할 |
| --- | --- | --- |
| `(root)` | 9 | REST API 본체 생성(`main.tf`), CloudWatch 로깅용 IAM 역할과 `aws_api_gateway_account`(`iam-role.tf`, `create_api_account` 변수로 선택), `context` 입력 정의(`variables-context.tf`), 출력(`ids` = `rest_api_id` + `resource_id`) |
| `domain` | 4 | 커스텀 도메인(`aws_api_gateway_domain_name`)을 REGIONAL/EDGE 엔드포인트 타입별로 생성하고, ACM 인증서 조회와 Route53 A 레코드(alias) 연결을 처리 |
| `method` | 4 | `aws_api_gateway_method`/`method_response`(`main.tf`)와 `aws_api_gateway_integration`/`integration_response`(`method-integration.tf`) 정의. MOCK+OPTIONS(CORS) 특수 처리 포함 |
| `stage` | 4 | `aws_api_gateway_deployment`·`stage`·`method_settings` 배포, 액세스 로그용 CloudWatch 로그 그룹(`cloudwatch.tf`), WAF Web ACL 연결 |
| `resource` | 3 | API 리소스 경로(`aws_api_gateway_resource`) 한 단계 생성. 계층 구조는 상위 모듈의 `ids` 출력을 `parent_ids`로 전달해 연결 |

서브모듈은 루트 모듈의 출력 `ids`(`{ rest_api_id, resource_id }`)를 `parent_ids` 입력으로 받아 체이닝된다. 소비자는 `//resource`, `//method` 같은 git 서브디렉터리 경로로 개별 서브모듈을 참조한다.

작업 전에 참고할 기존 문서는 다음과 같다.

- `README.md` — 모듈·서브모듈 사용 예시(HCL)와 terraform-docs 형식의 Requirements/Inputs/Outputs 표. 변수·출력 변경 시 이 표도 함께 갱신한다

## 4. 빌드 · 실행 · 테스트 명령

아래 명령은 프로젝트 설정 파일에서 자동 추출한 값이다. 실제 동작을 확인한 뒤 `확인 여부` 열을 갱신한다.

| 구분 | 명령 | 비고 |
| --- | --- | --- |
| 문법 검증 | `terraform init -backend=false && terraform validate` | 재사용 모듈이므로 저장소 단독으로는 validate까지만 가능 |
| 빌드(plan) | `terraform plan` | 저장소 루트에서 직접 실행 불가 — `api_name`, `context` 등 필수 입력이 없다. 이 모듈을 소비하는 프로젝트에서 실행한다 |
| 테스트 | `terraform test` | 테스트 파일(`*.tftest.hcl`)이 없어 현재 실행 대상 없음 |
| 정적 분석 | `terraform fmt -check -recursive` | 2026-08-20 기준 기존 파일 10개가 fmt 미준수로 실패한다. 작업 중 수정한 파일에만 `terraform fmt <파일>`을 적용하고, 저장소 전체 일괄 포맷팅은 하지 않는다 |

로컬 Terraform 버전은 v1.5.7이며 `versions.tf`의 `required_version >= 1.5.7`, AWS provider `>= 6.0.0`을 요구한다.

## 5. 코드 컨벤션

- 주 언어(Terraform)의 기존 스타일을 우선 따른다. 새로운 스타일을 도입하지 않는다.
- 소스 코드, 주석, 변수·함수·타입 명칭은 영문으로 작성한다.
- 마크다운 문서는 한글로 작성하며, 표 앞에는 반드시 한 줄을 띄운다.
- 수정 전 대상 파일과 호출부를 먼저 읽고, 기존 패턴과 일치하는 방식으로 구현한다.

저장소에서 실제 사용 중인 고유 패턴은 다음과 같다.

- 조건부 생성: 모든 리소스는 `count = var.create ? 1 : 0`(또는 파생 local) 패턴으로 생성 여부를 제어한다. 새 리소스도 같은 패턴을 따른다.
- 출력 안전 참조: count 기반 리소스의 속성은 `concat(resource.*.attr, [""])[0]`, `one(...)`, `try(..., "")` 패턴으로 빈 값 폴백을 두고 참조한다.
- 네이밍: 리소스 이름은 `var.context.name_prefix` 기반으로 조합한다 (예: `"${var.context.name_prefix}-${var.api_name}-api"`, 로그 그룹 `/apigateway/<name_prefix>-<api_name>-api`).
- 태깅: 모든 태그 지원 리소스는 `merge(var.context.tags, { Name = ... })`로 태그를 부여한다.
- 모듈 체이닝: 서브모듈은 `parent_ids = { rest_api_id, resource_id }` 객체를 입력으로 받는다. 인터페이스를 바꿀 때는 README 예시와 소비 프로젝트 호환성을 함께 고려한다.
- 변수 선언에는 `type`과 `description`을 함께 작성하고, 선택 변수는 `default = null`을 사용한다.
- IDE 포맷터 보호가 필요한 정렬 블록은 `// @formatter:off` / `// @formatter:on` 주석으로 감싼다.
- 하위 호환: 이 모듈은 git 태그로 배포되는 공유 모듈이다. 변수 삭제·이름 변경 등 브레이킹 체인지는 사용자에게 먼저 알리고 진행한다.

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
| 주요 테스트 경로 | 미탐지 |
| 테스트 명령 | `terraform test` |

Terraform 모듈 특성상 Mock 테스트는 `terraform test`의 `mock_provider` 블록을 사용한 `.tftest.hcl` 파일로 작성한다. 최소한 변경한 모듈은 `terraform init -backend=false && terraform validate`를 통과시킨다.

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

이 저장소는 재사용 Terraform 모듈로, 자체 시크릿·환경 변수·provider 자격 증명을 보유하지 않는다. AWS 자격 증명은 이 모듈을 소비하는 프로젝트의 provider 구성에서 주입되며, ARN·계정 ID·인증서 등 환경 의존 값은 변수 또는 `data` 소스로만 참조한다. 문서와 예시 코드에는 실제 계정 ID, ARN, 도메인 등 내부 식별 값을 하드코딩하지 않는다.

## 9. Git 작업 규칙

커밋 이력에서 탐지한 규칙은 다음과 같다.

| 항목 | 값 |
| --- | --- |
| 커밋 메시지 형식 | 자유 형식 |
| 일치 비율 | 0.3 |
| 현재 브랜치 | `feature/OI-1199` |

실제 커밋 예시는 다음과 같다.

- `Merge pull request #3 from oniops/feature/OI-887`
- `OI-887 IaC - integration_content_handling 변수 컨디션 조정`
- `Merge pull request #2 from oniops/feature/OI-887`

실제 관례는 다음과 같다.

- 커밋 제목은 `<Jira 티켓 ID> <한글 설명>` 형식이다 (예: `OI-887 IaC - 중복 변수 integration_http_method 제거`). 티켓 ID는 브랜치명에서 가져온다.
- 브랜치는 `feature/<티켓 ID>` 형식으로 만들고, PR을 통해 `main`에 머지한다.
- 릴리스는 `v1.x.x` 형식의 git 태그로 발행하며, 소비 프로젝트가 `?ref=v1.x.x`로 버전을 고정한다.

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
| 테스트 | 실제 네트워크·외부 API 호출 |
| 운영 | REAL 환경 대상 파괴적 작업 |
| Git | 파괴적 git 명령의 자동 실행 |
