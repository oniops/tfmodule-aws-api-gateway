# method

특정 API 리소스(경로)에 HTTP 메서드와 백엔드 통합을 정의하는 서브모듈 입니다.

API Gateway 에서 하나의 엔드포인트는 "클라이언트 → 메서드 요청 → 통합 요청 → 백엔드 → 통합 응답 → 메서드 응답 → 클라이언트" 의 흐름으로 처리 됩니다.
이 모듈은 이 네 단계를 한 번에 구성 합니다. 대상 리소스는 `parent_ids` 로 지정하며, 루트 모듈(`/`) 또는 `resource` 모듈의 `ids` 를 전달 합니다.

- 통합 타입(`type`)으로 백엔드 종류를 선택 합니다. `HTTP`/`HTTP_PROXY` 는 HTTP 백엔드, `AWS`/`AWS_PROXY` 는 Lambda 등 AWS 서비스, `MOCK` 은 백엔드 없이 응답을 반환 합니다.
  `*_PROXY` 는 요청·응답을 변환 없이 그대로 전달하고, 비 프록시 타입은 `request_templates`·`response_templates` 로 매핑을 정의 합니다.
- VPC 내부 백엔드는 `connection_type = "VPC_LINK"` 와 `connection_id` 로 연결 합니다.
- 인증은 `authorization`(기본 `NONE`)과 `authorizer_id`, `authorization_scopes`, `api_key_required` 로 지정 합니다.
- 메서드 응답·통합 응답은 기본적으로 `200` 상태로 함께 생성되며, `create_response = false` 로 건너뛸 수 있습니다.
- `MOCK` + `OPTIONS` 조합은 CORS Preflight 용도로 인식 합니다.

## Resources 역할

| 리소스 | 역할 |
| --- | --- |
| `aws_api_gateway_method` | 클라이언트가 호출하는 HTTP 메서드와 인증 방식, 요청 파라미터·모델·검증기를 정의 합니다 |
| `aws_api_gateway_integration` | 메서드 요청을 어떤 백엔드로 어떻게 전달할지(타입, URI, 연결, 요청 매핑, 타임아웃, 캐시 키)를 정의 합니다 |
| `aws_api_gateway_integration_response` | 백엔드 응답을 메서드 응답으로 매핑 합니다. `selection_pattern` 으로 응답을 선별하고 헤더·본문 변환을 정의 합니다 |
| `aws_api_gateway_method_response` | 클라이언트에 반환할 상태 코드와 허용 응답 헤더·모델을 정의 합니다 |

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.61.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_api_gateway_integration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration_response.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration_response) | resource |
| [aws_api_gateway_method.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method_response.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_response) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_api_key_required"></a> [api\_key\_required](#input\_api\_key\_required) | Specify if the method requires an API key | `bool` | `false` | no |
| <a name="input_authorization"></a> [authorization](#input\_authorization) | Type of authorization used for the method (NONE, CUSTOM, AWS\_IAM, COGNITO\_USER\_POOLS) | `string` | `"NONE"` | no |
| <a name="input_authorization_scopes"></a> [authorization\_scopes](#input\_authorization\_scopes) | Authorization scopes used when the authorization is `COGNITO_USER_POOLS`.<br/><br/>Ex)<br/>  authorization\_scopes = ["ApiGateway/api.write", "payments/inquiry"] | `list(string)` | `null` | no |
| <a name="input_authorizer_id"></a> [authorizer\_id](#input\_authorizer\_id) | Authorizer id to be used when the authorization is CUSTOM or COGNITO\_USER\_POOLS.<br/>An empty string is treated as unset (null).<br/><br/>Ex)<br/>  authorizer\_id = aws\_api\_gateway\_authorizer.this.id | `string` | `""` | no |
| <a name="input_cache_key_parameters"></a> [cache\_key\_parameters](#input\_cache\_key\_parameters) | List of cache key parameters for the integration. Support only for GET method, TTL value between 300 and 3600 seconds, Default is 300.<br/>see - https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-caching.html<br/>Ex)<br/>  # for proxy path<br/>  cache\_key\_parameters = ["method.request.path.proxy"]<br/><br/>  # for uri path<br/>  cache\_key\_parameters = ["method.request.path.users"] | `list(string)` | `null` | no |
| <a name="input_cache_namespace"></a> [cache\_namespace](#input\_cache\_namespace) | Integration's cache namespace. | `string` | `null` | no |
| <a name="input_connection_id"></a> [connection\_id](#input\_connection\_id) | ID of the VpcLink used for the integration. Required if connection\_type is VPC\_LINK | `string` | `null` | no |
| <a name="input_connection_type"></a> [connection\_type](#input\_connection\_type) | Integration input's connectionType. Valid connection\_type is INTERNET or VPC\_LINK | `string` | `null` | no |
| <a name="input_content_handling"></a> [content\_handling](#input\_content\_handling) | How to handle request payload content type conversions. Supported values are CONVERT\_TO\_BINARY and CONVERT\_TO\_TEXT. If not defined, payload will pass-through | `string` | `null` | no |
| <a name="input_create"></a> [create](#input\_create) | If true, creates the method, integration, and their response resources. | `bool` | `true` | no |
| <a name="input_create_response"></a> [create\_response](#input\_create\_response) | If true, creates the method response and integration response along with the method. Set to false to manage responses outside this module (e.g., for proxy integrations that do not need explicit response mappings). | `bool` | `true` | no |
| <a name="input_http_method"></a> [http\_method](#input\_http\_method) | HTTP Method (GET, POST, PUT, DELETE, HEAD, OPTIONS, ANY) | `string` | n/a | yes |
| <a name="input_http_method_integration"></a> [http\_method\_integration](#input\_http\_method\_integration) | Integration HTTP method calling the backend, one of GET, POST, PUT, DELETE, HEAD, OPTIONS, ANY, PATCH. Defaults to var.http\_method when not set (except for MOCK OPTIONS methods). Note that AWS service integrations such as Lambda can only be invoked via POST. | `string` | `null` | no |
| <a name="input_integration_content_handling"></a> [integration\_content\_handling](#input\_integration\_content\_handling) | How to handle response payload content type conversions on the integration response. Supported values are CONVERT\_TO\_BINARY and CONVERT\_TO\_TEXT. If not defined, the response payload will pass through. | `string` | `null` | no |
| <a name="input_integration_response_parameters"></a> [integration\_response\_parameters](#input\_integration\_response\_parameters) | A map of integration response parameters that maps backend or static values to method response headers sent to the caller.<br/><br/>For example:<br/>  integration\_response\_parameters = {<br/>    "method.response.header.Access-Control-Allow-Origin" = "'*'"<br/>  }<br/><br/>For CORS:<br/>  response\_parameters = {<br/>    "method.response.header.Access-Control-Allow-Origin"  = "'*'",<br/>    "method.response.header.Access-Control-Allow-Headers" = "'Origin, Accept, Content-Type, X-Requested-With, X-CSRF-Token, Authorization'",<br/>    "method.response.header.Access-Control-Allow-Methods" = "'GET, POST, PUT, DELETE, OPTIONS'"<br/>  } | `map(string)` | `null` | no |
| <a name="input_operation_name"></a> [operation\_name](#input\_operation\_name) | Function name that will be given to the method when generating an SDK through API Gateway. If omitted, API Gateway will generate a function name based on the resource path and HTTP verb. | `string` | `null` | no |
| <a name="input_parent_ids"></a> [parent\_ids](#input\_parent\_ids) | IDs of the parent - 'rest\_api\_id' of the REST API and 'resource\_id' of the API resource to attach the method to. Pass the 'ids' output of the root module or of a resource module. | <pre>object({<br/>    resource_id = string<br/>    rest_api_id = string<br/>  })</pre> | n/a | yes |
| <a name="input_passthrough_behavior"></a> [passthrough\_behavior](#input\_passthrough\_behavior) | Integration passthrough behavior (WHEN\_NO\_MATCH, WHEN\_NO\_TEMPLATES, NEVER). Required if request\_templates is used. | `string` | `"WHEN_NO_MATCH"` | no |
| <a name="input_request_models"></a> [request\_models](#input\_request\_models) | Map of the API models used for the request's content type where key is the content type (built-in model are Error and Empty.<br/><br/>EX)<br/>  request\_models = { "application/json" = "Error" }<br/>  request\_models = { "application/json" = "Empty" }<br/>  request\_models = { "application/json" = "<CustomDefinedModel>" } | `map(string)` | `null` | no |
| <a name="input_request_parameters"></a> [request\_parameters](#input\_request\_parameters) | Map of request parameters (from the path, query string and headers) that should be passed to the integration.<br/><br/>Ex)<br/>  request\_parameters = {<br/>      "method.request.path.proxy"         = true<br/>      "method.request.header.x-api-key"   = true<br/>      "method.request.header.x-signature" = true<br/>      "method.request.header.x-sig-date"  = true<br/>    } | `map(bool)` | `null` | no |
| <a name="input_request_parameters_integration"></a> [request\_parameters\_integration](#input\_request\_parameters\_integration) | Map of request query string parameters and headers that should be passed to the backend responder.<br/><br/>Ex)<br/>  request\_parameters\_integration = {<br/>    "integration.request.path.proxy"                 = "method.request.path.proxy"<br/>    "integration.request.header.x-api-key"           = "method.request.header.x-api-key"<br/>    "integration.request.header.X-Authorization"     = "'static'"<br/>    "integration.request.header.X-Some-Other-Header" = "method.request.header.X-Some-Header"<br/>  } | `map(string)` | `{}` | no |
| <a name="input_request_templates"></a> [request\_templates](#input\_request\_templates) | Map of the integration's payload request templates.<br/><br/>Ex)<br/>  # Transforms the incoming JSON request to JSON<br/>  request\_templates = {<br/>    "application/json" = <<eof<br/>    {<br/>      "name": "$input.params('name')",<br/>      "type": "$input.params('type')"<br/>    }<br/>    eof<br/>  }<br/><br/>  # Transforms the incoming XML request to JSON<br/>  request\_templates = {<br/>    "application/xml" = <<eof<br/>    {<br/>      "body" : $input.json('$')<br/>    }<br/>    eof<br/>  }<br/><br/>  # Transforms the incoming JSON request to JSON body include status 200<br/>  request\_templates = {<br/>    "application/json" = jsonencode({<br/>      statusCode = 200<br/>    }) | `map(any)` | `null` | no |
| <a name="input_request_validator_id"></a> [request\_validator\_id](#input\_request\_validator\_id) | The ID of an aws\_api\_gateway\_request\_validator to validate the request body and parameters. | `string` | `null` | no |
| <a name="input_response_models"></a> [response\_models](#input\_response\_models) | A map of the API models used for the response's content type<br/><br/>For example:<br/>  response\_models = {<br/>    "application/json" = aws\_api\_gateway\_model.response\_model.id<br/>  } | `map(string)` | `null` | no |
| <a name="input_response_parameters"></a> [response\_parameters](#input\_response\_parameters) | A map of response parameters that can be sent to the caller.<br/><br/>For example:<br/>  response\_parameters = {<br/>    "method.response.header.X-Some-Header" = true<br/>  }<br/><br/>For CORS:<br/>  response\_parameters = {<br/>    "method.response.header.Access-Control-Allow-Origin"  = true,<br/>    "method.response.header.Access-Control-Allow-Methods" = true,<br/>    "method.response.header.Access-Control-Allow-Headers" = true<br/>  } | `map(string)` | `null` | no |
| <a name="input_response_templates"></a> [response\_templates](#input\_response\_templates) | A map of response templates (by content type) used to transform the backend response payload before it is sent to the caller.<br/><br/>For example:<br/>  response\_templates = {<br/>      "application/xml" = <<-EOT<br/>  #set($inputRoot = $input.path('$'))<br/>  <?xml version="1.0" encoding="UTF-8"?><br/>  <message><br/>      $inputRoot.body<br/>  </message><br/>  EOT | `map(string)` | `null` | no |
| <a name="input_selection_pattern"></a> [selection\_pattern](#input\_selection\_pattern) | Specifies the regular expression pattern used to choose an integration response based on the response from the backend.<br/>Omit configuring this to make the integration the default one.<br/><br/>For example:<br/>  selection\_pattern = "Invalid.*"<br/>  selection\_pattern = "2\\d{2}"<br/>  selection\_pattern = "4\\d{2}"<br/>  selection\_pattern = "5\\d{2}" | `string` | `null` | no |
| <a name="input_status_code"></a> [status\_code](#input\_status\_code) | The HTTP status code of the method response and integration response. Defaults to '200' when not set. | `string` | `null` | no |
| <a name="input_timeout_milliseconds"></a> [timeout\_milliseconds](#input\_timeout\_milliseconds) | Custom timeout between 50 and 29,000 milliseconds. The default value is 29,000 milliseconds. | `number` | `29000` | no |
| <a name="input_type"></a> [type](#input\_type) | Integration input's type.<br/>An HTTP or HTTP\_PROXY integration with a connection\_type of VPC\_LINK is referred to as a private integration<br/>and uses a VpcLink to connect API Gateway to a network load balancer of a VPC.<br/><br/>Valid values<br/>  HTTP      : HTTP backends<br/>  HTTP\_PROXY: HTTP proxy integration<br/>  AWS       : AWS services<br/>  AWS\_PROXY : Lambda proxy integration<br/>  MOCK      : not calling any real backend | `string` | n/a | yes |
| <a name="input_uri"></a> [uri](#input\_uri) | Input's URI. Required if type is AWS, AWS\_PROXY, HTTP or HTTP\_PROXY | `string` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_http_method"></a> [http\_method](#output\_http\_method) | The HTTP method of the created method (e.g., GET, POST, ANY). Returns an empty string if the method is not created. |
| <a name="output_integration_http_method"></a> [integration\_http\_method](#output\_integration\_http\_method) | The HTTP method used to call the backend from the integration. Returns an empty string if the integration is not created or the value is not applicable (e.g., MOCK OPTIONS method). |
| <a name="output_integration_id"></a> [integration\_id](#output\_integration\_id) | The ID of the aws\_api\_gateway\_integration. Returns an empty string if the integration is not created. |
| <a name="output_method_id"></a> [method\_id](#output\_method\_id) | The ID of the aws\_api\_gateway\_method. Returns an empty string if the method is not created. |
| <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id) | The ID of the API resource this method is attached to, passed through from parent\_ids. |
| <a name="output_rest_api_id"></a> [rest\_api\_id](#output\_rest\_api\_id) | The ID of the REST API, passed through from parent\_ids. |
<!-- END_TF_DOCS -->