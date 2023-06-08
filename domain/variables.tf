variable "public_domain_prefix" {
  type = string
}

variable "endpoint_type" {
  type = string
  description = "List of endpoint types. This resource currently only supports managing a single value. Valid values: EDGE or REGIONAL"
  default = "REGIONAL"
  validation {
    condition     = contains(["EDGE", "REGIONAL"], var.endpoint_type)
    error_message = "Valid endpoint_type is one of EDGE, REGIONAL."
  }
}

variable "exists_public_hosting_zone" {
  type    = bool
  default = true
}

