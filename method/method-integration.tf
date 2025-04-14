locals {
  integration_http_method = var.http_method_integration != null ? var.http_method_integration : local.option_method ? null : var.http_method
}

resource "aws_api_gateway_integration" "this" {
  count                   = local.create ? 1 : 0
  rest_api_id             = var.parent_ids.rest_api_id
  resource_id             = var.parent_ids.resource_id
  http_method             = concat(aws_api_gateway_method.this.*.http_method, [""])[0]
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
  # credentials
  # tls_config
}

resource "aws_api_gateway_integration_response" "this" {
  count               = local.create_response ? 1 : 0
  rest_api_id         = var.parent_ids.rest_api_id
  resource_id         = var.parent_ids.resource_id
  http_method         = one(aws_api_gateway_method.this.*.http_method)
  status_code         = one(aws_api_gateway_method_response.this.*.status_code)
  selection_pattern   = var.selection_pattern
  response_parameters = var.integration_response_parameters
  content_handling    = var.integration_content_handling
  response_templates  = var.response_templates

  depends_on = [
    aws_api_gateway_method_response.this,
    aws_api_gateway_integration.this
  ]
}
