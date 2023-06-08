output "domain_name" {
  value = local.domain_name
}

output "gateway_domain_name" {
  value = var.endpoint_type == "REGIONAL" ? concat(aws_api_gateway_domain_name.regional.*.regional_domain_name, [""])[0] : concat(aws_api_gateway_domain_name.edge.*.regional_domain_name, [""])[0]
}
