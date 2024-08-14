locals {
  create = var.create
}

resource "aws_api_gateway_resource" "this" {
  count       = local.create ? 1 : 0
  parent_id   = var.parent_ids.resource_id
  rest_api_id = var.parent_ids.rest_api_id
  path_part   = var.path_part
}
