variable "context" {
  description = "Provides standardized naming policy and attribute information for data source reference to define cloud resources for a Project."
  type        = any
}

variable "create" {
  type        = bool
  description = "If true, creates the deployment, stage, method settings, log group, and WAF association."
  default     = true
}

variable "name" {
  type        = string
  description = "The name of the stage (e.g., dev, stg, prod). Used as the stage_name and the Name tag."
}

variable "api_name" {
  type        = string
  description = "The name of the API Gateway, used to build the access-log CloudWatch log group name '/apigateway/{name_prefix}-{api_name}-api'. If set to null, var.name is used instead."
}

variable "description" {
  type        = string
  description = "The description of the stage."
  default     = null
}

variable "deployment_description" {
  type        = string
  description = "The description of the deployment (aws_api_gateway_deployment)."
  default     = null
}

variable "documentation_version" {
  type        = string
  description = "The version of API Specification. aws_api_gateway_documentation_version.<resource_id>.version"
  default     = null
}

variable "xray_tracing_enabled" {
  type        = bool
  description = "Whether active tracing with X-ray is enabled. Defaults to false."
  default     = false
}

variable "cache_cluster_size" {
  type        = string
  description = "Size of the cache cluster for the stage, if enabled. Allowed values include 0.5, 1.6, 6.1, 13.5, 28.4, 58.2, 118 and 237."
  default     = null
}

variable "cache_cluster_enabled" {
  type        = bool
  description = "Whether a cache cluster is enabled for the stage"
  default     = false
}

variable "rest_api_id" {
  type        = string
  description = "The ID of the REST API to deploy to this stage."
}

variable "redeployment" {
  type        = string
  description = <<EOF
Arbitrary string used as the redeployment trigger. The API is redeployed whenever the SHA1 hash of this value changes.
Typically pass the jsonencode-d contents of the files that define the API, so that any change to them triggers redeployment.

Ex)
  redeployment = jsonencode([
    file("main.tf"),
    file("apigw_user.tf"),
    file("apigw_dept.tf"),
  ])
EOF
  default     = ""
}

variable "enable_access_logs" {
  type        = bool
  description = "If true, creates a CloudWatch log group and enables access logging on the stage."
  default     = false
}

variable "access_log_format" {
  type        = string
  description = "Formatting and values recorded in the logs. see - https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-logging.html"
  default     = "{\"requestId\":\"$context.requestId\", \"extendedRequestId\":\"$context.extendedRequestId\", \"ip\": \"$context.identity.sourceIp\", \"caller\":\"$context.identity.caller\", \"user\":\"$context.identity.user\", \"requestTime\":\"$context.requestTime\", \"httpMethod\":\"$context.httpMethod\", \"resourcePath\":\"$context.resourcePath\", \"status\":\"$context.status\", \"protocol\":\"$context.protocol\", \"responseLength\":\"$context.responseLength\"}"
}

variable "retention_in_days" {
  description = "Retention period (in days) of the access-log CloudWatch log group."
  type        = number
  default     = 90
}

variable "canary_deployment" {
  description = "Flag to decide whether canary deployment exist."
  type        = bool
  default     = false
}

variable "canary_traffic_percentage" {
  description = "Percent 0.0 - 100.0 of traffic to divert to the canary deployment."
  type        = number
  default     = 10.0
}

variable "use_stage_cache" {
  description = "Whether the canary deployment uses the stage cache."
  type        = bool
  default     = false
}

variable "canary_variables" {
  description = "(Optional) Map of overridden stage variables (including new variables) for the canary deployment."
  type        = map(string)
  default     = {}
}

variable "deployment_id" {
  description = "ID of the deployment that the canary points to."
  type        = string
  default     = null
}


variable "method_settings" {
  type = list(object({
    method_path = string
    settings    = map(any)
  }))
  description = <<EOF
List of method settings applied to the stage (aws_api_gateway_method_settings). Each entry consists of a
'method_path' (e.g., "*/*" for all methods) and a 'settings' map. Note that logging_level and metrics require
the account-level CloudWatch role to be configured (see 'create_api_account' of the root module).

Ex)
  method_settings    = [
    {
      method_path = "*/*"
      settings    = {
        logging_level                              = "INFO"
        metrics_enabled                            = true
        data_trace_enabled                         = true
        caching_enabled                            = true
        cache_data_encrypted                       = true
        require_authorization_for_cache_control    = true
        cache_ttl_in_seconds                       = 300
        throttling_burst_limit                     = -1
        throttling_rate_limit                      = -1
        unauthorized_cache_control_header_strategy = "SUCCEED_WITH_RESPONSE_HEADER"
      }
    },
  ]

  # logging_level is one of OFF, ERROR, INFO
  # unauthorized_cache_control_header_strategy is one of FAIL_WITH_403, SUCCEED_WITH_RESPONSE_HEADER, SUCCEED_WITHOUT_RESPONSE_HEADER
EOF
  default     = []
}

variable "web_acl_arn" {
  description = "ARN of the WebAcl(WAF-v2) associated with the Stage."
  type        = string
  default     = null
}