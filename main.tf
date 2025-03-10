locals {
  api_gw_name = "${var.context.name_prefix}-${var.api_name}-api"
  description = var.description == null ? "${local.api_gw_name} RestAPI Gateway" : var.description
}

resource "aws_api_gateway_rest_api" "this" {
  count = var.create ? 1 : 0

  name               = local.api_gw_name
  description        = local.description
  binary_media_types = var.binary_media_types

  tags = merge(var.context.tags, {
    Name = local.api_gw_name
  })

  #    endpoint_configuration {
  #      types = [var.endpoint_type]
  #    }
}
