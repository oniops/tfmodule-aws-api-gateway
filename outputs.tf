output "api_gw_name" {
  description = "The full name of the API Gateway REST API, built as '{name_prefix}-{api_name}-api'."
  value       = local.api_gw_name
}

output "resource_id" {
  description = "The resource ID of the REST API's root resource ('/'). Returns an empty string if the REST API is not created."
  value       = try(aws_api_gateway_rest_api.this[0].root_resource_id, "")
}

output "rest_api_id" {
  description = "The ID of the REST API. Returns an empty string if the REST API is not created."
  value       = try(aws_api_gateway_rest_api.this[0].id, "")
}

output "ids" {
  description = "Object containing rest_api_id and the root resource_id. Pass this as 'parent_ids' to the resource and method submodules to chain the API hierarchy."
  value = {
    resource_id = try(aws_api_gateway_rest_api.this[0].root_resource_id, "")
    rest_api_id = try(aws_api_gateway_rest_api.this[0].id, "")
  }
}

output "cloudwatch_role_arn" {
  description = "The ARN of the IAM role registered on the account-level API Gateway settings for CloudWatch logging. Returns an empty string unless create_api_account is true."
  value       = try(aws_api_gateway_account.apigw_account[0].cloudwatch_role_arn, "")
}
