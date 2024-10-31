locals {
  create = var.create
  cloudwatch_log_group_name = format("/apigateway/%s-%s-api", var.context.name_prefix, var.api_name == null ? var.name : var.api_name)
  tags   = var.context.tags
}

resource "aws_api_gateway_deployment" "this" {
  stage_name        = var.deployment_stage_name
  stage_description = var.description
  rest_api_id       = var.rest_api_id

  triggers = {
    redeployment = sha1(var.redeployment)
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "this" {
  count                 = local.create ? 1 : 0
  stage_name            = var.name
  description           = var.description
  rest_api_id           = var.rest_api_id
  deployment_id         = aws_api_gateway_deployment.this.id
  documentation_version = var.documentation_version
  xray_tracing_enabled  = var.xray_tracing_enabled
  cache_cluster_enabled = var.cache_cluster_enabled
  cache_cluster_size    = var.cache_cluster_size
  web_acl_arn           = var.web_acl_arn

  dynamic "access_log_settings" {
    for_each = var.enable_access_logs ? [true] : []

    content {
      # ARN of the CloudWatch Logs log group or Kinesis Data Firehose delivery stream to receive access logs.
      destination_arn = concat(aws_cloudwatch_log_group.this.*.arn, [""])[0]
      format = replace(var.access_log_format, "\n", "")
    }
  }

  dynamic "canary_settings" {
    for_each = var.canary_deployment ? [1] : []

    content {
      percent_traffic          = var.canary_traffic_percentage
      use_stage_cache          = var.use_stage_cache
      stage_variable_overrides = var.canary_variables
    }
  }

  tags = merge(local.tags,
    { Name = var.name }
  )

  depends_on = [
    aws_api_gateway_deployment.this,
    aws_cloudwatch_log_group.this
  ]
}

locals {
  method_settings_count = local.create && var.enable_access_logs ? length(var.method_settings) : 0
}

resource "aws_api_gateway_method_settings" "this" {
  count = local.method_settings_count

  method_path = var.method_settings[count.index]["method_path"]
  rest_api_id = var.rest_api_id
  stage_name  = var.name

  settings {
    logging_level = lookup(var.method_settings[count.index]["settings"], "logging_level", "INFO")
    metrics_enabled = lookup(var.method_settings[count.index]["settings"], "metrics_enabled", false)
    data_trace_enabled = lookup(var.method_settings[count.index]["settings"], "data_trace_enabled", false)
    caching_enabled = lookup(var.method_settings[count.index]["settings"], "caching_enabled", false)
    cache_data_encrypted = lookup(var.method_settings[count.index]["settings"], "cache_data_encrypted", false)
    cache_ttl_in_seconds = lookup(var.method_settings[count.index]["settings"], "cache_ttl_in_seconds", null)
    throttling_burst_limit = lookup(var.method_settings[count.index]["settings"], "throttling_burst_limit", -1)
    throttling_rate_limit = lookup(var.method_settings[count.index]["settings"], "throttling_rate_limit", -1)
    unauthorized_cache_control_header_strategy = lookup(var.method_settings[count.index]["settings"], "unauthorized_cache_control_header_strategy", null)
  }
  depends_on = [
    aws_api_gateway_stage.this
  ]
}
