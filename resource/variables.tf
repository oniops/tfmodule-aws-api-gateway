# for aws_api_gateway_resource
variable "create" {
  type        = bool
  description = "If true, creates the API Gateway resource."
  default     = true
}

# for aws_api_gateway_resource
variable "parent_ids" {
  type = object({
    resource_id = string
    rest_api_id = string
  })
  description = "IDs of the parent - 'rest_api_id' of the REST API and 'resource_id' of the parent resource. Pass the 'ids' output of the root module (for a top-level path) or of an upper resource module to chain the path hierarchy."
}

variable "path_part" {
  type        = string
  description = "Last path segment of this API resource (e.g., 'v1', 'users'). Use greedy path syntax like '{proxy+}' to define a proxy resource."
}
