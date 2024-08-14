# tfmodule-aws-api-gateway
AWS API Gateway 리소스를 구성 합니다. 

## Modules

### tfmodule-aws-api-gateway
RESTFul 메서드 및 서비스 통합을 위한 API 리소스를 생성 합니다.

```
locals {
  project          = module.ctx.project
  name_prefix      = module.ctx.name_prefix
  region           = module.ctx.region
  tags             = module.ctx.tags
  openapi_dns_name = data.aws_lb.openapi.dns_name
  account_id       = data.aws_caller_identity.current.account_id
  deployed_stage   = local.project
}

module "ctx" {
  source  = "git::https://code.bespinglobal.com/scm/op/tfmodule-context.git?ref=v1.0.0"
  context = {
    project      = "gstg"
    region       = "ap-northeast-2"
    environment  = "Stage"
    owner        = "aws_opsnow_gstg@opsnow.com"
    department   = "OpsNow"
    customer     = "OpsNow Global STG"
    domain       = "gstg.opsnow.com"
    pri_domain   = "backend.opsnow.com"
    s3_prefix_cd = "region"
  }
}

# ROOT
module "api" {
  source             = "git::https://code.bespinglobal.com/scm/op/tfmodule-aws-api-gateway.git?ref=v1.1.0"
  context            = module.ctx.context
  api_name           = var.api_name
  create_api_account = false
}

# /{proxy+}
module "proxy" {
  source     = "../../resource"
  parent_ids = module.api.ids
  path_part  = "{proxy+}"
}

# /{proxy+}ANY
module "proxyAny" {
  source             = "../../method"
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
  source             = "../../stage"
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
    module.billProxyAny,
    module.identityProxyAny,
    module.platProxyAny,
    module.pushPxyAny,
  ]
}

resource "aws_apigatewayv2_api_mapping" "this" {
  api_id          = module.api.rest_api_id
  domain_name     = data.aws_api_gateway_domain_name.this.domain_name
  api_mapping_key = var.api_mapping_key
  stage           = local.deployed_stage
  depends_on      = [module.stage]
}


```

### domain
API Gateway 애플리케이션의 Endpoint 는 REGIONAL, EDGE, PRIVATE 을 대상으로 구성할 수 있으며, REGIONAL, EDGE 는 public 도메인에 연결 할 수 있습니다.  
- `REGIONAL` 은 Region 내의 Client 를 위한 Endpoint 로 Region ACM 인증서가 필요
- `EDGE` 는 글로벌과 연결되는 Client 를 위한 Endpoint 로 CloudFront 와 연결되므로 반드시 'us-east-1' 리전에 구성된 ACM 인증서가 필요     

```hcl

```

- [api-gateway-api-endpoint-types](https://docs.aws.amazon.com/ko_kr/apigateway/latest/developerguide/api-gateway-api-endpoint-types.html)

<br>

### resource
API 리소스를 구성 합니다. 
RESTFul 리소스는 Hierarchy 구조를 가지므로, `parent_ids` 속성으로 상위 리소스를 정의 하여야 합니다.

```hcl

```

<br>

### method
API 리소스 주소를 대상으로 HTTP Method 및 Integration (통합) 방식을 정의 합니다. 

HTTP 메서드를 통합 하기 위한 상위 리소스 `parent_ids` 를 지정 하여야 합니다.

```hcl

```

<br>

### stage
API Gateway 리소스를 Stage 런타임 환경으로 배포 합니다. 

```hcl

```

<br>

## Input
|     |     |     |     |     |
|-----|-----|-----|-----|-----|
|     |     |     |     |     |
|     |     |     |     |     |
|     |     |     |     |     |
|     |     |     |     |     |
|     |     |     |     |     |
|     |     |     |     |     |

<br>

## Output
|     |     |     |     |     |
|-----|-----|-----|-----|-----|
|     |     |     |     |     |
|     |     |     |     |     |
|     |     |     |     |     |
|     |     |     |     |     |
|     |     |     |     |     |
|     |     |     |     |     |


<br>



## Example

- [simple](./examples/simple/HELP.md) 예제는 API Gateway 의 요청을 HTTP 프로토콜 통합하여 Target URI 에 통합 합니다. 
- [proxy-vpclink](./examples/proxy-vpclink/HELP.md) 예제는 API Gateway 의 모든 요청을 VPC Link 연결을 통해 Network Load Balancer 으로 통합 합니다. 

<br>


## References

  


