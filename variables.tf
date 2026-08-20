variable "create" {
  type        = bool
  description = "If true, creates the API Gateway REST API. Set to false to skip resource creation while keeping the module wired in."
  default     = true
}

variable "create_api_account" {
  type        = bool
  description = "If true, creates an IAM role for pushing logs to CloudWatch and registers it on the account-level API Gateway settings (aws_api_gateway_account). This setting is global per AWS account and region, so enable it in only one module instance."
  default     = false
}

variable "api_name" {
  type        = string
  description = "The name of the API Gateway REST API. The full resource name is built as '{name_prefix}-{api_name}-api'."
}

variable "description" {
  type        = string
  description = "The description of the API Gateway REST API. If not set, defaults to '{full API name} RestAPI Gateway'."
  default     = null
}

variable "binary_media_types" {
  type        = list(string)
  description = "List of binary media types (MIME types) supported by the REST API, such as 'application/octet-stream' or 'image/png'. By default, the REST API supports only UTF-8-encoded text payloads."
  default     = null
}
