locals {
  create          = var.create
  option_method   = var.type == "MOCK" && var.http_method == "OPTIONS"
  create_response = local.create && (var.status_code == null || var.response_models != null || var.response_parameters != null)
  status_code     = local.create_response && var.status_code == null ? "200" : var.status_code
}

resource "aws_api_gateway_method" "this" {
  count                = local.create ? 1 : 0
  rest_api_id          = var.parent_ids.rest_api_id
  resource_id          = var.parent_ids.resource_id
  http_method          = var.http_method
  authorization        = var.authorization
  authorizer_id        = var.authorizer_id == "" ? null : var.authorizer_id
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
  http_method         = aws_api_gateway_method.this[0].http_method
  status_code         = local.status_code
  response_models     = var.response_models
  response_parameters = var.response_parameters
}
