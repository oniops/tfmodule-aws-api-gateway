output "rest_api_id" {
  description = "The ID of the REST API, passed through from parent_ids."
  value       = var.parent_ids.rest_api_id
}

output "resource_id" {
  description = "The ID of the API resource this method is attached to, passed through from parent_ids."
  value       = var.parent_ids.resource_id
}

output "method_id" {
  description = "The ID of the aws_api_gateway_method. Returns an empty string if the method is not created."
  value       = try(aws_api_gateway_method.this[0].id, "")
}

output "http_method" {
  description = "The HTTP method of the created method (e.g., GET, POST, ANY). Returns an empty string if the method is not created."
  value       = try(aws_api_gateway_method.this[0].http_method, "")
}

output "integration_id" {
  description = "The ID of the aws_api_gateway_integration. Returns an empty string if the integration is not created."
  value       = try(aws_api_gateway_integration.this[0].id, "")
}

output "integration_http_method" {
  description = "The HTTP method used to call the backend from the integration. Returns an empty string if the integration is not created or the value is not applicable (e.g., MOCK OPTIONS method)."
  value       = try(aws_api_gateway_integration.this[0].integration_http_method, "")
}
