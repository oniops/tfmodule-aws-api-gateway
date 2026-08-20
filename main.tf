locals {
  api_gw_name = "${var.context.name_prefix}-${var.api_name}-api"
  description = coalesce(var.description, "${local.api_gw_name} RestAPI Gateway")
}

resource "aws_api_gateway_rest_api" "this" {
  count = var.create ? 1 : 0

  name               = local.api_gw_name
  description        = local.description
  binary_media_types = var.binary_media_types

  dynamic "endpoint_configuration" {
    for_each = var.endpoint_type == null ? [] : [var.endpoint_type]

    content {
      types = [endpoint_configuration.value]
    }
  }

  tags = merge(var.context.tags, {
    Name = local.api_gw_name
  })
}
