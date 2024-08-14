variable "create" {
  type        = bool
  description = "If this vIf value is true, creates an API Gateway."
  default     = true
}

variable "create_api_account" {
  type        = bool
  description = "If this vIf value is true, creates an API Gateway Account."
  default     = false
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

variable "binary_media_types" {
  type        = list(string)
  description = " List of binary media types supported by the REST API. By default, the REST API supports only UTF-8-encoded text payloads. "
  default     = null
}
