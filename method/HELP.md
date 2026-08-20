<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

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
| <a name="input_authorizer_id"></a> [authorizer\_id](#input\_authorizer\_id) | Authorizer id to be used when the authorization is CUSTOM or COGNITO\_USER\_POOLS<br/><br/>Ex)<br/>  authorizer\_id = aws\_api\_gateway\_authorizer.this.id | `string` | `""` | no |
| <a name="input_cache_key_parameters"></a> [cache\_key\_parameters](#input\_cache\_key\_parameters) | List of cache key parameters for the integration. Support only for GET method, TTL value between 300 and 3600 seconds, Default is 300.<br/>see - https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-caching.html<br/>Ex)<br/>  # for proxy path<br/>  cache\_key\_parameters = ["method.request.path.proxy"]<br/><br/>  # for uri path<br/>  cache\_key\_parameters = ["method.request.path.users"] | `list(string)` | `null` | no |
| <a name="input_cache_namespace"></a> [cache\_namespace](#input\_cache\_namespace) | Integration's cache namespace. | `string` | `null` | no |
| <a name="input_connection_id"></a> [connection\_id](#input\_connection\_id) | ID of the VpcLink used for the integration. Required if connection\_type is VPC\_LINK | `string` | `null` | no |
| <a name="input_connection_type"></a> [connection\_type](#input\_connection\_type) | Integration input's connectionType. Valid connection\_type is INTERNET or VPC\_LINK | `string` | `null` | no |
| <a name="input_content_handling"></a> [content\_handling](#input\_content\_handling) | How to handle request payload content type conversions. Supported values are CONVERT\_TO\_BINARY and CONVERT\_TO\_TEXT. If not defined, payload will pass-through | `string` | `null` | no |
| <a name="input_create"></a> [create](#input\_create) | for aws\_api\_gateway\_method | `bool` | `true` | no |
| <a name="input_http_method"></a> [http\_method](#input\_http\_method) | HTTP Method (GET, POST, PUT, DELETE, HEAD, OPTIONS, ANY) | `string` | n/a | yes |
| <a name="input_http_method_integration"></a> [http\_method\_integration](#input\_http\_method\_integration) | HTTP Method one of GET, POST, PUT, DELETE, HEAD, OPTIONs, ANY and PATCH. but AWS integrations. e.g., Lambda function can only be invoked via POST | `string` | `null` | no |
| <a name="input_integration_content_handling"></a> [integration\_content\_handling](#input\_integration\_content\_handling) | How to handle request payload content type conversions. Supported values are CONVERT\_TO\_BINARY and CONVERT\_TO\_TEXT. If not defined, payload will pass-through | `string` | `null` | no |
| <a name="input_integration_response_parameters"></a> [integration\_response\_parameters](#input\_integration\_response\_parameters) | A map of response parameters that can be sent to the caller.<br/><br/>For example:<br/>  response\_parameters\_integration = {<br/>    "method.response.header.Access-Control-Allow-Origin" = "'*'"<br/>  }<br/><br/>For CORS:<br/>  response\_parameters = {<br/>    "method.response.header.Access-Control-Allow-Origin"  = "'*'",<br/>    "method.response.header.Access-Control-Allow-Headers" = "'Origin, Accept, Content-Type, X-Requested-With, X-CSRF-Token, Authorization'",<br/>    "method.response.header.Access-Control-Allow-Methods" = "'GET, POST, PUT, DELETE, OPTIONS'"<br/>  } | `map(string)` | `null` | no |
| <a name="input_operation_name"></a> [operation\_name](#input\_operation\_name) | Function name that will be given to the method when generating an SDK through API Gateway. If omitted, API Gateway will generate a function name based on the resource path and HTTP verb. | `string` | `null` | no |
| <a name="input_parent_ids"></a> [parent\_ids](#input\_parent\_ids) | The Resource ID and API Instance ID of the REST API | <pre>object({<br/>    resource_id = string<br/>    rest_api_id = string<br/>  })</pre> | n/a | yes |
| <a name="input_passthrough_behavior"></a> [passthrough\_behavior](#input\_passthrough\_behavior) | Integration passthrough behavior (WHEN\_NO\_MATCH, WHEN\_NO\_TEMPLATES, NEVER). Required if request\_templates is used. | `string` | `"WHEN_NO_MATCH"` | no |
| <a name="input_request_models"></a> [request\_models](#input\_request\_models) | Map of the API models used for the request's content type where key is the content type (built-in model are Error and Empty.<br/><br/>EX)<br/>  request\_models = { "application/json" = "Error" }<br/>  request\_models = { "application/json" = "Empty" }<br/>  request\_models = { "application/json" = "<CustomDefinedModel>" } | `map(string)` | `null` | no |
| <a name="input_request_parameters"></a> [request\_parameters](#input\_request\_parameters) | Map of request parameters (from the path, query string and headers) that should be passed to the integration.<br/><br/>Ex)<br/>  request\_parameters = {<br/>      "method.request.path.proxy"         = true<br/>      "method.request.header.x-api-key"   = true<br/>      "method.request.header.x-signature" = true<br/>      "method.request.header.x-sig-date"  = true<br/>    } | `map(bool)` | `null` | no |
| <a name="input_request_parameters_integration"></a> [request\_parameters\_integration](#input\_request\_parameters\_integration) | Map of request query string parameters and headers that should be passed to the backend responder.<br/><br/>Ex)<br/>  request\_parameters\_integration = {<br/>    "integration.request.path.proxy"                 = "method.request.path.proxy"<br/>    "integration.request.header.x-api-key"           = "method.request.header.x-api-key"<br/>    "integration.request.header.X-Authorization"     = "'static'"<br/>    "integration.request.header.X-Some-Other-Header" = "method.request.header.X-Some-Header"<br/>  } | `map(string)` | `{}` | no |
| <a name="input_request_templates"></a> [request\_templates](#input\_request\_templates) | Map of the integration's payload request templates.<br/><br/>Ex)<br/>  # Transforms the incoming JSON request to JSON<br/>  request\_templates = {<br/>    "application/json" = <<eof<br/>    {<br/>      "name": "$input.params('name')",<br/>      "type": "$input.params('type')"<br/>    }<br/>    eof<br/>  }<br/><br/>  # Transforms the incoming XML request to JSON<br/>  request\_templates = {<br/>    "application/xml" = <<eof<br/>    {<br/>      "body" : $input.json('$')<br/>    }<br/>    eof<br/>  }<br/><br/>  # Transforms the incoming JSON request to JSON body include status 200<br/>  request\_templates = {<br/>    "application/json" = jsonencode({<br/>      statusCode = 200<br/>    }) | `map` | `null` | no |
| <a name="input_request_validator_id"></a> [request\_validator\_id](#input\_request\_validator\_id) | ID of a aws\_api\_gateway\_request\_validator | `string` | `null` | no |
| <a name="input_response_models"></a> [response\_models](#input\_response\_models) | A map of the API models used for the response's content type<br/><br/>For example:<br/>  response\_models = {<br/>    "application/json" = aws\_api\_gateway\_model.response\_model.id<br/>  } | `map(string)` | `null` | no |
| <a name="input_response_parameters"></a> [response\_parameters](#input\_response\_parameters) | A map of response parameters that can be sent to the caller.<br/><br/>For example:<br/>  response\_parameters = {<br/>    "method.response.header.X-Some-Header" = true<br/>  }<br/><br/>For CORS:<br/>  response\_parameters = {<br/>    "method.response.header.Access-Control-Allow-Origin"  = true,<br/>    "method.response.header.Access-Control-Allow-Methods" = true,<br/>    "method.response.header.Access-Control-Allow-Headers" = true<br/>  } | `map(string)` | `null` | no |
| <a name="input_response_templates"></a> [response\_templates](#input\_response\_templates) | A map of response parameters that can be sent to the caller.<br/><br/>For example:<br/>  response\_templates = {<br/>      "application/xml" = <<-EOT<br/>  #set($inputRoot = $input.path('$'))<br/>  <?xml version="1.0" encoding="UTF-8"?><br/>  <message><br/>      $inputRoot.body<br/>  </message><br/>  EOT | `map(string)` | `null` | no |
| <a name="input_selection_pattern"></a> [selection\_pattern](#input\_selection\_pattern) | Specifies the regular expression pattern used to choose an integration response based on the response from the backend.<br/>Omit configuring this to make the integration the default one.<br/><br/>For example:<br/>  selection\_pattern = "Invalid.*"<br/>  selection\_pattern = "2\\d{2}"<br/>  selection\_pattern = "4\\d{2}"<br/>  selection\_pattern = "5\\d{2}" | `string` | `null` | no |
| <a name="input_status_code"></a> [status\_code](#input\_status\_code) | The HTTP status code | `string` | `null` | no |
| <a name="input_timeout_milliseconds"></a> [timeout\_milliseconds](#input\_timeout\_milliseconds) | Custom timeout between 50 and 29,000 milliseconds. The default value is 29,000 milliseconds. | `number` | `29000` | no |
| <a name="input_type"></a> [type](#input\_type) | Integration input's type.<br/>An HTTP or HTTP\_PROXY integration with a connection\_type of VPC\_LINK is referred to as a private integration<br/>and uses a VpcLink to connect API Gateway to a network load balancer of a VPC.<br/><br/>Valid values<br/>  HTTP      : HTTP backends<br/>  HTTP\_PROXY: HTTP proxy integration<br/>  AWS       : AWS services<br/>  AWS\_PROXY : Lambda proxy integration<br/>  MOCK      : not calling any real backend | `string` | n/a | yes |
| <a name="input_uri"></a> [uri](#input\_uri) | Input's URI. Required if type is AWS, AWS\_PROXY, HTTP or HTTP\_PROXY | `string` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_http_method"></a> [http\_method](#output\_http\_method) | n/a |
| <a name="output_integration_http_method"></a> [integration\_http\_method](#output\_integration\_http\_method) | n/a |
| <a name="output_integration_id"></a> [integration\_id](#output\_integration\_id) | n/a |
| <a name="output_method_id"></a> [method\_id](#output\_method\_id) | n/a |
| <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id) | n/a |
| <a name="output_rest_api_id"></a> [rest\_api\_id](#output\_rest\_api\_id) | n/a |
<!-- END_TF_DOCS -->