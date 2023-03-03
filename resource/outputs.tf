output "resource_id" {
  value = concat(aws_api_gateway_resource.this.*.id, [""])[0]
}

output "rest_api_id" {
  value = concat(aws_api_gateway_resource.this.*.rest_api_id, [""])[0]
}

output "ids" {
  value = {
    resource_id = concat(aws_api_gateway_resource.this.*.id, [""])[0]
    rest_api_id = concat(aws_api_gateway_resource.this.*.rest_api_id, [""])[0]
  }
}
