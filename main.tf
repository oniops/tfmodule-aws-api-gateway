locals {
  api_gw_name = format("%s-%s-api", var.context.name_prefix, var.api_name)
  description = var.description == null ? format("%s RestAPI Gateway", local.api_gw_name) : var.description
}

resource "aws_api_gateway_rest_api" "this" {
  count = var.create ? 1 : 0

  name               = local.api_gw_name
  description        = local.description
  binary_media_types = var.binary_media_types

  tags = merge( var.context.tags, {
    Name = local.api_gw_name
  })

  #    endpoint_configuration {
  #      types = [var.endpoint_type]
  #    }
}
