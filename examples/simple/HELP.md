# simple

간단한 API Gateway 애플리케이션을 배포 합니다.

API Gateway 통합 으로 `HTTP` 프로토콜을 통한 `INTERNET` 연결로 `http://api.something.private:8080` 을 타겟으로 포워딩하는 RESTFul API 를 정의 하는 예제 입니다. 

<br>

## Root API

API Gateway 의 애플리케이션 이름을 결정 합니다.   
API Gateway 의 이름은 Context 정보를 참조 하여 {project}-{region_alias}-{api_name}-{resource_suffix} 으로 정의 됩니다.

apple 인경우 'otcmp-as1d-apple-api' 

```hcl
module "api" {
  source   = "../../"
  context  = module.ctx.context
  api_name = "apple"
}
```

<br>

## users 리소스 추가
`/users` 주소를 가지는 API Resource 를 생성 합니다.  

`users` 리소스는 최상위 API 주소 `/` 하위에 추가 되어야 하므로 `parent_ids` 속성을 `api` 모듈의 `ids` 속성을 참조합니다.
`path_part` 는 현재 URI 리소스를 결정 합니다.

참고로 `api` 와 같은 상위 리소스의 `ids` 속성은 `resource_id`, `rest_api_id` 속성을 포함하고 있습니다. 


```hcl
module "users" {
  source     = "../../resource/"
  parent_ids = module.api.ids
  path_part  = "users"
}
```

## users/GET 메서드 추가
`/users` 주소의 GET 메서드를 추가 합니다.

`parent_ids` 속성은 상위 모듈 `module.users.ids` 을 참조 합니다. 

```hcl
module "users_get" {
  source             = "../../method/"
  parent_ids         = module.users.ids
  http_method        = "GET"
  type               = "HTTP"
  connection_type    = "INTERNET"
  uri                = "http://api.something.private:8080/users"
  request_parameters = {
    "method.request.querystring.name"  = true
    "method.request.querystring.email" = false
  }
  request_parameters_integration = {
    "integration.request.querystring.name"  = "method.request.querystring.name"
    "integration.request.querystring.email" = "method.request.querystring.email"
  }
}
```

- URL querystring 을 통해 파라미터를 전달 하고자 한다면  `request_parameters` 속성에는 `method.request.querystring` 접두어로 시작하는 이름을 정의하고  
`request_parameters_integration` 속성에는 `integration.request.querystring` 접두어로 동일한 이름으로 매핑 하면 됩니다. 

<br>


```
http://somedomain:8080?type=01&code=A1&lang=
```

만약 위와 같이 `type`, `code`, `lang` 파라미터를 전달 하고, 이 중 type, code 는 필수로 전달되어야 하고, lang 은 선택적이라고 한다면  
`request_parameters` 속성과 `request_parameters_integration` 속성은 다음과 같습니다.

```hcl
  request_parameters = {
    "method.request.querystring.type" = true
    "method.request.querystring.code" = true
    "method.request.querystring.lang" = false
  }

  request_parameters_integration = {
    "integration.request.querystring.type" = "method.request.querystring.type"
    "integration.request.querystring.code" = "method.request.querystring.code"
    "integration.request.querystring.lang" = "method.request.querystring.lang"
  }
```

<br>


## users/{id} 리소스 추가 
RESTFul API 는 사용자 정보를 액세스 할 때 `{id}` 에 해당하는 리소스를 식별 하고,URI 경로 파라미터를 기준으로 사용자를 조회, 수정, 삭제 하게 됩니다. 

`/users/{id}` API 리소스를 생성 합니다. 
```hcl
module "users_id" {
  source     = "../../resource/"
  parent_ids = module.users.ids
  path_part  = "{id}"
}
```

<br>

## users/{id} GET 메서드 추가

`/users/{id}` URI 를 대상으로 GET 메서드를 생성하고 HTTP 유형으로 통합 하는 예제 입니다. 

```hcl
# /users/{id} GET
module "users_id_get" {
  source             = "../../method/"
  parent_ids         = module.users_id.ids
  http_method        = "GET"
  type               = "HTTP"
  connection_type    = "INTERNET"
  uri                = "http://api.something.private:8080/users/{id}"
  request_parameters = {
    "method.request.path.id" = true
  }
  request_parameters_integration = {
    "integration.request.path.id"             = "method.request.path.id"
  }
}
```

위와 같이 URI 경로 파라미터 `id`를 전달 하는 `request_parameters` 속성과 `request_parameters_integration` 속성은 다음과 같습니다.

```hcl
  request_parameters = {
    "method.request.path.id" = true
  }
  request_parameters_integration = {
    "integration.request.path.id" = "method.request.path.id"
  }
```
