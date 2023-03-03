output "api_gw_name" {
  value = local.api_gw_name
}

output "resource_id" {
  value = concat(aws_api_gateway_rest_api.this.*.root_resource_id, [""])[0]
}

output "rest_api_id" {
  value = concat(aws_api_gateway_rest_api.this.*.id, [""])[0]
}

output "ids" {
  value = {
    resource_id = concat(aws_api_gateway_rest_api.this.*.root_resource_id, [""])[0]
    rest_api_id = concat(aws_api_gateway_rest_api.this.*.id, [""])[0]
  }
}

output "cloudwatch_role_arn" {
  value = try(aws_api_gateway_account.apigw_account.cloudwatch_role_arn, "")
}
