# for aws_api_gateway_method
variable "create" {
  type    = bool
  default = true
}

# for aws_api_gateway_resource
variable "parent_ids" {
  type = object({
    resource_id = string
    rest_api_id = string
  })
  description = "The Resource ID and API Instance ID of the REST API"
}

variable "rest_api_id" {
  type        = string
  description = "The Resource Instance ID of the REST API"
  default = null
}

variable "resource_id" {
  type        = string
  description = "The Resource ID of the REST API"
  default = null
}

variable "path_part" {
  type        = string
  description = "Last path segment of this API resource. (v1, users). Define proxy path like `{proxy+}`"
}
