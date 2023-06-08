# for aws_api_gateway_method
variable "parent_ids" {
  type = object({
    resource_id = string
    rest_api_id = string
  })
  description = "The Resource ID and API Instance ID of the REST API"
}

#variable "rest_api_id" {
#  type        = string
#  description = "The Resource Instance ID of the REST API"
#  default     = null
#}
#
#variable "resource_id" {
#  type        = string
#  description = "The Resource ID of the REST API"
#  default     = null
#}

variable "http_method" {
  type        = string
  description = "HTTP Method (GET, POST, PUT, DELETE, HEAD, OPTIONS, ANY)"
  validation {
    condition     = contains(["GET", "POST", "PUT", "DELETE", "HEAD", "OPTIONS", "ANY"], var.http_method)
    error_message = "Valid http_method is one of GET, POST, PUT, DELETE, HEAD, OPTIONS, ANY"
  }
}

variable "authorization" {
  type        = string
  description = "Type of authorization used for the method (NONE, CUSTOM, AWS_IAM, COGNITO_USER_POOLS)"
  default     = "NONE"
}


variable "authorizer_id" {
  type        = string
  description = "Authorizer id to be used when the authorization is CUSTOM or COGNITO_USER_POOLS"
  default     = null
  #  validation {
  #    condition     = contains(["CUSTOM", "COGNITO_USER_POOLS"], var.authorization) && var.authorizer_id == null
  #    error_message = "Require setting the authorizer_id when the authorization is CUSTOM or COGNITO_USER_POOLS"
  #  }
}

variable "request_parameters" {
  type        = map(bool)
  description = <<EOF
Map of request parameters (from the path, query string and headers) that should be passed to the integration.

Ex)
  request_parameters = {
      "method.request.path.proxy"         = true
      "method.request.header.x-api-key"   = true
      "method.request.header.x-signature" = true
      "method.request.header.x-sig-date"  = true
    }
EOF
  default     = {}
}

variable "authorization_scopes" {
  type        = list(string)
  description = <<EOF
Authorization scopes used when the authorization is `COGNITO_USER_POOLS`.

Ex)
  authorization_scopes = ["ApiGateway/api.write", "payments/inquiry"]
EOF

  default = null
}

variable "api_key_required" {
  type        = bool
  description = "Specify if the method requires an API key"
  default     = false
}

variable "operation_name" {
  type        = string
  description = "Function name that will be given to the method when generating an SDK through API Gateway. If omitted, API Gateway will generate a function name based on the resource path and HTTP verb."
  default     = null
}

variable "request_models" {
  type        = map(string)
  description = <<EOF
Map of the API models used for the request's content type where key is the content type (built-in model are Error and Empty.

EX)
  request_models = { "application/json" = "Error" }
  request_models = { "application/json" = "Empty" }
  request_models = { "application/json" = "<CustomDefinedModel>" }
EOF

  default = null
}

variable "request_validator_id" {
  type        = string
  description = " ID of a aws_api_gateway_request_validator"
  default     = null
}

### for aws_api_gateway_integration

variable "type" {
  type        = string
  description = <<EOF
Integration input's type.
An HTTP or HTTP_PROXY integration with a connection_type of VPC_LINK is referred to as a private integration
and uses a VpcLink to connect API Gateway to a network load balancer of a VPC.

Valid values
  HTTP      : HTTP backends
  HTTP_PROXY: HTTP proxy integration
  AWS       : AWS services
  AWS_PROXY : Lambda proxy integration
  MOCK      : not calling any real backend
EOF

  validation {
    condition     = contains(["HTTP", "HTTP_PROXY", "AWS", "AWS_PROXY", "MOCK"], var.type)
    error_message = "Valid api-gateway integration type is one of HTTP, HTTP_PROXY, AWS, AWS_PROXY or MOCK."
  }
}

variable "connection_type" {
  type        = string
  description = "Integration input's connectionType. Valid connection_type is INTERNET or VPC_LINK"
  default     = null
}

variable "connection_id" {
  type        = string
  description = "ID of the VpcLink used for the integration. Required if connection_type is VPC_LINK"
  default     = null
}

variable "timeout_milliseconds" {
  type        = number
  description = "Custom timeout between 50 and 29,000 milliseconds. The default value is 29,000 milliseconds."
  default     = 29000
}

variable "request_parameters_integration" {
  type        = map(string)
  description = <<EOF
Map of request query string parameters and headers that should be passed to the backend responder.

Ex)
  request_parameters_integration = {
    "integration.request.path.proxy"                 = "method.request.path.proxy"
    "integration.request.header.x-api-key"           = "method.request.header.x-api-key"
    "integration.request.header.X-Authorization"     = "'static'"
    "integration.request.header.X-Some-Other-Header" = "method.request.header.X-Some-Header"
  }
EOF

  default = {}
}

variable "request_templates" {
  type        = map
  description = <<EOF
Map of the integration's payload request templates.

Ex)
  # Transforms the incoming JSON request to JSON
  request_templates = {
    "application/json" = <<eof
    {
      "name": "$input.params('name')",
      "type": "$input.params('type')"
    }
    eof
  }

  # Transforms the incoming XML request to JSON
  request_templates = {
    "application/xml" = <<eof
    {
      "body" : $input.json('$')
    }
    eof
  }

  # Transforms the incoming JSON request to JSON body include status 200
  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
EOF
  default     = null

}

variable "content_handling" {
  type        = string
  description = "How to handle request payload content type conversions. Supported values are CONVERT_TO_BINARY and CONVERT_TO_TEXT. If not defined, payload will pass-through"
  default     = null
  validation {
    condition     = var.content_handling == null || can(regex("^(CONVERT_TO_TEXT|CONVERT_TO_BINARY)$", var.content_handling))
    #  var.content_handling == "CONVERT_TO_TEXT" #  contains(["CONVERT_TO_TEXT", "CONVERT_TO_BINARY"], var.content_handling+"")
    error_message = "Valid content_handling is one of CONVERT_TO_TEXT or CONVERT_TO_BINARY."
  }
}

variable "integration_http_method" {
  type        = string
  description = "HTTP Method one of GET, POST, PUT, DELETE, HEAD, OPTIONs, ANY and PATCH. but AWS integrations. e.g., Lambda function can only be invoked via POST"
  default     = null
}

variable "uri" {
  type        = string
  description = "Input's URI. Required if type is AWS, AWS_PROXY, HTTP or HTTP_PROXY"
  default     = null
}

variable "passthrough_behavior" {
  type        = string
  description = "Integration passthrough behavior (WHEN_NO_MATCH, WHEN_NO_TEMPLATES, NEVER). Required if request_templates is used."
  default     = "WHEN_NO_MATCH"
  validation {
    condition     = contains(["WHEN_NO_MATCH", "WHEN_NO_TEMPLATES", "NEVER"], var.passthrough_behavior)
    error_message = "Valid passthrough_behavior is one of WHEN_NO_MATCH, WHEN_NO_TEMPLATES or NEVER."
  }
}

variable "cache_namespace" {
  type        = string
  description = "Integration's cache namespace."
  default     = null
}

variable "cache_key_parameters" {
  type        = list(string)
  description = <<EOF
List of cache key parameters for the integration. Support only for GET method, TTL value between 300 and 3600 seconds, Default is 300.
see - https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-caching.html
Ex)
  # for proxy path
  cache_key_parameters = ["method.request.path.proxy"]

  # for uri path
  cache_key_parameters = ["method.request.path.users"]
EOF

  default = null
}

# Response
variable "status_code" {
  type        = string
  description = "The HTTP status code"
  default     = "200"
}

variable "response_models" {
  type        = map(string)
  description = <<EOF
A map of the API models used for the response's content type

For example:
  response_models = {
    "application/json" = aws_api_gateway_model.response_model.id
  }
EOF

  default = null
}

variable "response_parameters" {
  type        = map(string)
  description = <<EOF
A map of response parameters that can be sent to the caller.

For example:
  response_parameters = {
    "method.response.header.X-Some-Header" = true
  }
EOF

  default = null
}
