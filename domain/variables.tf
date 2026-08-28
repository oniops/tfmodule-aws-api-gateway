variable "context" {
  description = "Provides standardized naming policy and attribute information for data source reference to define cloud resources for a Project."
  type        = any
}

variable "public_domain_prefix" {
  type        = string
  description = "Host prefix of the custom domain name. The full domain name is built as '{public_domain_prefix}.{domain}' (e.g., 'api' becomes api.mycompany.com)."
}

variable "endpoint_type" {
  type        = string
  description = "Endpoint type of the custom domain name. Valid values: REGIONAL or EDGE. EDGE is served through CloudFront and therefore requires an ACM certificate issued in the us-east-1 region."
  default     = "REGIONAL"
  validation {
    condition     = contains(["EDGE", "REGIONAL"], var.endpoint_type)
    error_message = "Valid endpoint_type is one of EDGE, REGIONAL."
  }
}

variable "exists_public_hosting_zone" {
  type        = bool
  description = "If true, looks up the public Route53 hosted zone of the domain and creates an alias A record pointing to the API Gateway domain name. Set to false when the DNS record is managed outside this module."
  default     = true
}

variable "domain" {
  type        = string
  description = "Base public domain name used to look up the ACM certificate and the Route53 hosted zone (e.g., 'mycompany.com'). Defaults to context.domain when not set."
  default     = null
}
