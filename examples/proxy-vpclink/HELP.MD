# proxy-vpclink

API Gateway 를 통한 Proxy 애플리케이션을 배포 합니다.

API Gateway 통합 으로 `HTTP_PROXY` 프로토콜을 통한 `VPC_LINK` 연결로 네트워크 로드 밸런서의 Endpoint 를 타겟으로 포워딩 할 수 있습니다. 

<br>


## Root API

API Gateway 의 애플리케이션 이름을 결정 합니다.   
API Gateway 의 이름은 Context 정보를 참조 하여 {project}-{region_alias}-{api_name}-{resource_suffix} 으로 정의 됩니다.

banana 인경우 'otcmp-as1d-banana-api' 

```hcl
module "api" {
  source   = "../../"
  context  = module.ctx.context
  api_name = "banana"
}
```

<br>

## api-v2 리소스 추가
`/api-v2` 주소를 가지는 API Resource 를 생성 합니다.

`api-v2` 리소스는 최상위 API 주소 `/` 하위에 추가 되어야 하므로 상위 `parent_ids` 속성을 `app` 모듈의 `ids` 속성을 참조합니다.   
`path_part` 는 현재 URI 리소스를 결정 합니다.

```hcl
module "api_v2" {
  source     = "../../resource/"
  parent_ids = module.api.ids
  path_part  = "api-v2"
}
```
<br>

## api_v2_proxy 리소스 추가
`/api-v2/{proxy+}` 주소를 가지는 API Resource 를 생성 합니다.  
`parent_ids` 속성 참조를 `module.api_v2.ids` 으로 하고 있습니다. 
 
```hcl
module "api_v2_proxy" {
  source     = "../../resource/"
  parent_ids = module.api_v2.ids
  path_part  = "{proxy+}"
}
```

<br>

## api_v2_proxy_any 메서드 추가
`/api-v2/{proxy+}` 주소 URI 에 ANY 메서드를 추가 합니다.   
`http_method` 속성을 `ANY` 로 하는 경우 HTTP 의 모든 Method 가 적용 됩니다.   

```hcl
module "api_v2_proxy_any" {
  source             = "../../method/"
  parent_ids         = module.api_v2_proxy.ids
  type               = "HTTP_PROXY"
  http_method        = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = data.aws_api_gateway_vpc_link.this.id
  uri                = format("%s/error", local.nlb_endpoint_uri)
  request_parameters = {
    "method.request.path.proxy" = true
  }
  request_parameters_integration = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}
```

- 다음은 API Gateway 의 HTTP 메서드가 AWS Backend 로 통합(Integraion) 되는 중요 속성입니다.
```
  type               = "HTTP_PROXY"
  http_method        = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = data.aws_api_gateway_vpc_link.this.id
  uri                = format("%s/error", local.nlb_endpoint_uri) 
```
 
- 리소스 URI 하위 경로인 {proxy+} 경로를 사용하기 위해서 `method.request.path.proxy` 를 다음과 같이 `request_parameters` 와 `request_parameters_integration` 를 정의 해야 합니다.  
```hcl
  request_parameters = {
    "method.request.path.proxy" = true
  }

  request_parameters_integration = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
```
