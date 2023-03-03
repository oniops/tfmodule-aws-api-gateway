resource "aws_api_gateway_resource" "this" {
  parent_id   = var.parent_ids.resource_id
  rest_api_id = var.parent_ids.rest_api_id
  path_part   = var.path_part
}
