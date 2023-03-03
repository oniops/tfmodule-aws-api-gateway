variable "create_api_gateway" {
  type        = bool
  description = "If this vIf value is true, creates an API Gateway."
  default     = true
}

variable "api_name" {
  type        = string
  description = "The name of API Gateway REST-API"
}

variable "description" {
  type        = string
  description = "The description of API Gateway REST-API"
  default     = null
}
