output "resource_id" {
  description = "The ID of the created API resource. Returns an empty string if the resource is not created."
  value       = concat(aws_api_gateway_resource.this.*.id, [""])[0]
}

output "rest_api_id" {
  description = "The ID of the REST API this resource belongs to. Returns an empty string if the resource is not created."
  value       = concat(aws_api_gateway_resource.this.*.rest_api_id, [""])[0]
}

output "ids" {
  description = "Object containing rest_api_id and this resource's resource_id. Pass this as 'parent_ids' to child resource modules or method modules to chain the API hierarchy."
  value = {
    resource_id = concat(aws_api_gateway_resource.this.*.id, [""])[0]
    rest_api_id = concat(aws_api_gateway_resource.this.*.rest_api_id, [""])[0]
  }
}

output "path" {
  description = "The complete path of this API resource including all parent paths (e.g., '/v1/users'). Returns an empty string if the resource is not created."
  value       = try(aws_api_gateway_resource.this[0].path, "")
}

output "path_part" {
  description = "The last path segment of this API resource. Returns an empty string if the resource is not created."
  value       = try(aws_api_gateway_resource.this[0].path_part, "")
}
