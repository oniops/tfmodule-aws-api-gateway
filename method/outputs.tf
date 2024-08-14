output "rest_api_id" {
  value = var.parent_ids.rest_api_id
}

output "resource_id" {
  value = var.parent_ids.resource_id
}

output "method_id" {
  value = try(aws_api_gateway_method.this[0].id, "")
}

output "http_method" {
  value = try(aws_api_gateway_method.this[0].http_method, "")
}

output "integration_id" {
  value = try(aws_api_gateway_integration.this[0].id, "")
}

output "integration_http_method" {
  value = try(aws_api_gateway_integration.this[0].integration_http_method, "")
}
