# tfmodule-aws-api-gateway

RESTFul 메서드 및 서비스 통합을 위한 AWS API Gateway REST API 리소스를 프로비저닝 합니다.

루트 모듈이 REST API 본체를 생성하고, 서브모듈(`resource`, `method`, `stage`, `domain`)을 조합하여
리소스 계층 → 메서드/통합 → 스테이지 배포 → 커스텀 도메인 연결까지 구성 합니다.
각 서브모듈은 상위 모듈의 `ids` 출력(`{ rest_api_id, resource_id }`)을 `parent_ids` 입력으로 받아 체이닝 됩니다.

## Usage

```hcl

variable "team"             { default = "DevOps" }
variable "api_name"         { default = "demo" }
variable "api_mapping_key"  { default = "demo/v1" }

module "ctx" {
  source  = "git::https://code.bespinglobal.com/scm/op/tfmodule-context.git?ref=v1.0.0"
  context = {
    project      = "demo"
    region       = "ap-northeast-2"
    environment  = "Development"
    owner        = "demo@mycompany.com"
    customer     = "My Company"
    domain       = "mycompany.com"
    pri_domain   = "mycompany.local"
  }
}


locals {
  account_id       = module.ctx.account_id
  region           = module.ctx.region
  project          = module.ctx.project
  name_prefix      = module.ctx.name_prefix
  openapi_dns_name = data.aws_lb.openapi.dns_name
  deployed_stage   = local.project
  tags             = module.ctx.tags
}

# ROOT
module "api" {
  source             = "git::https://code.bespinglobal.com/scm/op/tfmodule-aws-api-gateway.git?ref=v1.2.2"
  context            = module.ctx.context
  api_name           = var.api_name
  create_api_account = false
}

# /{proxy+}
module "proxy" {
  source     = "git::https://code.bespinglobal.com/scm/op/tfmodule-aws-api-gateway.git?ref=v1.2.2//resource"
  parent_ids = module.api.ids
  path_part  = "{proxy+}"
}

# /{proxy+}ANY
module "proxyAny" {
  source             = "git::https://code.bespinglobal.com/scm/op/tfmodule-aws-api-gateway.git?ref=v1.2.2//method"
  parent_ids         = module.proxy.ids
  http_method        = "ANY"
  type               = "HTTP_PROXY"
  connection_type    = "VPC_LINK"
  connection_id      = data.aws_api_gateway_vpc_link.this.id
  uri                = format("http://%s:9001/platform/v1/{proxy}", local.openapi_dns_name)
  request_parameters = {
    "method.request.path.proxy" = true
  }
  request_parameters_integration = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
  passthrough_behavior = "WHEN_NO_MATCH"

  response_models = {
    "application/json" = "Empty"
  }
}

# deploy to stage
module "stage" {
  source             = "git::https://code.bespinglobal.com/scm/op/tfmodule-aws-api-gateway.git?ref=v1.2.2//stage"
  name               = local.deployed_stage
  api_name           = var.api_name
  context            = module.ctx.context
  rest_api_id        = module.api.rest_api_id
  enable_access_logs = true
  method_settings    = [
    {
      method_path = "*/*"
      settings    = {
        logging_level   = "ERROR"
        metrics_enabled = true
      }
    },
  ]
  depends_on = [
    module.api,
    module.proxyAny,
  ]
}

resource "aws_apigatewayv2_api_mapping" "this" {
  api_id          = module.api.rest_api_id
  domain_name     = "api.mycompany.com"
  api_mapping_key = var.api_mapping_key
  stage           = local.deployed_stage
  depends_on      = [module.stage]
}


```


### domain
API Gateway 애플리케이션의 Endpoint 는 REGIONAL, EDGE, PRIVATE 을 대상으로 구성할 수 있으며, REGIONAL, EDGE 는 public 도메인에 연결 할 수 있습니다.  
- `REGIONAL` 은 Region 내의 Client 를 위한 Endpoint 로 Region ACM 인증서가 필요
- `EDGE` 는 글로벌과 연결되는 Client 를 위한 Endpoint 로 CloudFront 와 연결되므로 반드시 'us-east-1' 리전에 구성된 ACM 인증서가 필요     

전체 도메인 이름은 `<public_domain_prefix>.<domain>` 으로 조합되며, `domain` 미지정 시 `context.domain` 을 사용 합니다.
`exists_public_hosting_zone = true`(기본값) 인 경우 도메인의 public Route53 호스팅 존을 조회하여 alias A 레코드를 생성 합니다.

```hcl

# api.mycompany.com → API Gateway REGIONAL 커스텀 도메인
module "domain" {
  source               = "git::https://code.bespinglobal.com/scm/op/tfmodule-aws-api-gateway.git?ref=v1.2.2//domain"
  context              = module.ctx.context
  public_domain_prefix = "api"
  endpoint_type        = "REGIONAL"
}

```

- [api-gateway-api-endpoint-types](https://docs.aws.amazon.com/ko_kr/apigateway/latest/developerguide/api-gateway-api-endpoint-types.html)

<br>

### resource
API 리소스를 구성 합니다. 
RESTFul 리소스는 Hierarchy 구조를 가지므로, `parent_ids` 속성으로 상위 리소스를 정의 하여야 합니다.
루트 모듈 또는 상위 `resource` 모듈의 `ids` 출력을 그대로 전달 합니다.

```hcl

# /v1
module "v1" {
  source     = "git::https://code.bespinglobal.com/scm/op/tfmodule-aws-api-gateway.git?ref=v1.2.2//resource"
  parent_ids = module.api.ids
  path_part  = "v1"
}

# /v1/users
module "users" {
  source     = "git::https://code.bespinglobal.com/scm/op/tfmodule-aws-api-gateway.git?ref=v1.2.2//resource"
  parent_ids = module.v1.ids
  path_part  = "users"
}

# /v1/users/{proxy+} - greedy path 는 `{proxy+}` 형식으로 정의 합니다.
module "usersProxy" {
  source     = "git::https://code.bespinglobal.com/scm/op/tfmodule-aws-api-gateway.git?ref=v1.2.2//resource"
  parent_ids = module.users.ids
  path_part  = "{proxy+}"
}

```

<br>

### method
API 리소스 주소를 대상으로 HTTP Method 및 Integration (통합) 방식을 정의 합니다. 

HTTP 메서드를 통합 하기 위한 상위 리소스 `parent_ids` 를 지정 하여야 합니다.

통합 타입(`type`)은 `HTTP`, `HTTP_PROXY`, `AWS`, `AWS_PROXY`, `MOCK` 을 지원 합니다.
`authorization` 이 `CUSTOM` 또는 `COGNITO_USER_POOLS` 인 경우 `authorizer_id` 를 지정 합니다.

```hcl

# GET /v1/users → HTTP 백엔드 통합
module "usersGet" {
  source      = "git::https://code.bespinglobal.com/scm/op/tfmodule-aws-api-gateway.git?ref=v1.2.2//method"
  parent_ids  = module.users.ids
  http_method = "GET"
  type        = "HTTP"
  uri         = "http://backend.mycompany.local/v1/users"

  response_models = {
    "application/json" = "Empty"
  }
}

# OPTIONS /v1/users → MOCK 통합 (CORS Preflight)
module "usersOptions" {
  source      = "git::https://code.bespinglobal.com/scm/op/tfmodule-aws-api-gateway.git?ref=v1.2.2//method"
  parent_ids  = module.users.ids
  http_method = "OPTIONS"
  type        = "MOCK"

  request_templates = {
    "application/json" = jsonencode({ statusCode = 200 })
  }

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }

  integration_response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET, POST, PUT, DELETE, OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Origin, Accept, Content-Type, X-Requested-With, Authorization'"
  }
}

```

<br>

### stage
API Gateway 리소스를 Stage 런타임 환경으로 배포 합니다. 

- `redeployment` 값의 SHA1 해시가 변경될 때마다 재배포가 트리거 됩니다. API 를 정의한 파일 내용을 `jsonencode` 로 전달하면 파일 변경 시 자동 재배포 됩니다.
- `enable_access_logs = true` 인 경우 CloudWatch 로그 그룹(`/apigateway/<name_prefix>-<api_name>-api`)을 생성하고 액세스 로그를 활성화 합니다. `method_settings` 도 이 옵션이 활성화된 경우에만 적용 됩니다.
- `web_acl_arn` 을 지정하면 WAF(v2) Web ACL 을 스테이지에 연결 합니다.

```hcl

module "stage" {
  source             = "git::https://code.bespinglobal.com/scm/op/tfmodule-aws-api-gateway.git?ref=v1.2.2//stage"
  context            = module.ctx.context
  name               = "dev"
  api_name           = var.api_name
  rest_api_id        = module.api.rest_api_id
  enable_access_logs = true
  retention_in_days  = 90

  redeployment = jsonencode([
    file("${path.module}/main.tf"),
  ])

  method_settings = [
    {
      method_path = "*/*"
      settings    = {
        logging_level   = "INFO"
        metrics_enabled = true
      }
    },
  ]
}

```


## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | `>= 1.5.7` |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | `>= 6.0.0` |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | `>= 6.0.0` |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_api_gateway_account.apigw_account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_account) | resource |
| [aws_api_gateway_rest_api.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api) | resource |
| [aws_iam_role.apigw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.apigw_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy.apigw_cw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy_document.assume_apigw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_api_name"></a> [api\_name](#input\_api\_name) | The name of the API Gateway REST API. The full resource name is built as '{name\_prefix}-{api\_name}-api'. | `string` | n/a | yes |
| <a name="input_binary_media_types"></a> [binary\_media\_types](#input\_binary\_media\_types) | List of binary media types (MIME types) supported by the REST API, such as 'application/octet-stream' or 'image/png'. By default, the REST API supports only UTF-8-encoded text payloads. | `list(string)` | `null` | no |
| <a name="input_context"></a> [context](#input\_context) | Provides standardized naming policy and attribute information for data source reference to define cloud resources for a Project. | <pre>object({<br/>    region       = string # describe default region to create a resource from aws<br/>    project      = string # project name is usally account's project name or platform name<br/>    environment  = string # Runtime Environment such as develop, stage, production<br/>    owner        = string # project owner<br/>    team         = string # Team name of Devops Transformation<br/>    name_prefix  = string # resource name prefix<br/>    pri_domain   = string # private domain name (ex, tools.customer.co.kr)<br/>    tags         = map(string)<br/>  })</pre> | n/a | yes |
| <a name="input_create"></a> [create](#input\_create) | If true, creates the API Gateway REST API. Set to false to skip resource creation while keeping the module wired in. | `bool` | `true` | no |
| <a name="input_create_api_account"></a> [create\_api\_account](#input\_create\_api\_account) | If true, creates an IAM role for pushing logs to CloudWatch and registers it on the account-level API Gateway settings (aws\_api\_gateway\_account). This setting is global per AWS account and region, so enable it in only one module instance. | `bool` | `false` | no |
| <a name="input_description"></a> [description](#input\_description) | The description of the API Gateway REST API. If not set, defaults to '{full API name} RestAPI Gateway'. | `string` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_api_gw_name"></a> [api\_gw\_name](#output\_api\_gw\_name) | The full name of the API Gateway REST API, built as '{name\_prefix}-{api\_name}-api'. |
| <a name="output_cloudwatch_role_arn"></a> [cloudwatch\_role\_arn](#output\_cloudwatch\_role\_arn) | The ARN of the IAM role registered on the account-level API Gateway settings for CloudWatch logging. Returns an empty string unless create\_api\_account is true. |
| <a name="output_ids"></a> [ids](#output\_ids) | Object containing rest\_api\_id and the root resource\_id. Pass this as 'parent\_ids' to the resource and method submodules to chain the API hierarchy. |
| <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id) | The resource ID of the REST API's root resource ('/'). Returns an empty string if the REST API is not created. |
| <a name="output_rest_api_id"></a> [rest\_api\_id](#output\_rest\_api\_id) | The ID of the REST API. Returns an empty string if the REST API is not created. |

