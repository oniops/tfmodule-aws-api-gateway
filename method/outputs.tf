output "rest_api_id" {
  value = var.parent_ids.rest_api_id
}

output "resource_id" {
  value = var.parent_ids.resource_id
}


output "api_method_id" {
  value = aws_api_gateway_method.this.id
}

output "http_method" {
  value = aws_api_gateway_method.this.http_method
}

output "api_integration_id" {
  value = aws_api_gateway_integration.this.id
}
