locals {
  integration_http_method = var.http_method_integration != null ? var.http_method_integration : var.http_method
  create_response         = var.status_code == null || var.response_models != null || var.response_parameters != null ? true : false
  status_code             = local.create_response && var.status_code == null ? "200" : var.status_code
}

resource "aws_api_gateway_method" "this" {
  rest_api_id          = var.parent_ids.rest_api_id
  resource_id          = var.parent_ids.resource_id
  http_method          = var.http_method
  authorization        = var.authorization
  request_parameters   = var.request_parameters
  request_models       = var.request_models
  authorization_scopes = var.authorization_scopes
  api_key_required     = var.api_key_required
  operation_name       = var.operation_name
  request_validator_id = var.request_validator_id
}

resource "aws_api_gateway_method_response" "this" {
  count               = local.create_response ? 1 : 0
  rest_api_id         = var.parent_ids.rest_api_id
  resource_id         = var.parent_ids.resource_id
  http_method         = aws_api_gateway_method.this.http_method
  status_code         = local.status_code
  response_models     = var.response_models
  response_parameters = var.response_parameters
}

resource "aws_api_gateway_integration" "this" {
  rest_api_id             = var.parent_ids.rest_api_id
  resource_id             = var.parent_ids.resource_id
  http_method             = concat(aws_api_gateway_method.this.*.http_method, [""])[0]
  id                      = var.integration_id
  integration_http_method = local.integration_http_method
  type                    = var.type
  connection_type         = var.connection_type
  connection_id           = var.connection_id
  timeout_milliseconds    = var.timeout_milliseconds
  request_parameters      = var.request_parameters_integration
  request_templates       = var.request_templates
  content_handling        = var.content_handling
  uri                     = var.uri
  passthrough_behavior    = var.passthrough_behavior
  cache_key_parameters    = var.cache_key_parameters
  cache_namespace         = var.cache_namespace
  # response_parameters     = var.response_parameters_integration
  # credentials
  # tls_config
}

resource "aws_api_gateway_integration_response" "this" {
  count               = local.create_response ? 1 : 0
  rest_api_id         = var.parent_ids.rest_api_id
  resource_id         = var.parent_ids.resource_id
  http_method         = concat(aws_api_gateway_method.this.*.http_method, [""])[0]
  status_code         = concat(aws_api_gateway_method_response.this.*.status_code, [""])[0]
  selection_pattern   = var.selection_pattern
  response_parameters = var.response_parameters_integration
  content_handling    = var.content_handling_integration
  response_templates  = var.response_template
  depends_on          = [
    aws_api_gateway_integration.this
  ]
}
