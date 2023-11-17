output "rest_api_id" {
  value = var.parent_ids.rest_api_id
}

output "resource_id" {
  value = var.parent_ids.resource_id
}


output "method_id" {
  value = aws_api_gateway_method.this.id
}

output "http_method" {
  value = aws_api_gateway_method.this.http_method
}

output "integration_id" {
  value = aws_api_gateway_integration.this.id
}

output "integration_http_method" {
  value = aws_api_gateway_integration.this.integration_http_method
}

