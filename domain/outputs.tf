output "domain_name" {
  description = "The custom domain name of the API Gateway, built as '{public_domain_prefix}.{domain}'."
  value       = local.domain_name
}

output "gateway_domain_name" {
  description = "The AWS-side target domain name of the API Gateway custom domain, used as the DNS alias target. Returns the regional domain name for REGIONAL and the CloudFront domain name for EDGE. Returns an empty string if the domain is not created."
  value       = var.endpoint_type == "REGIONAL" ? try(aws_api_gateway_domain_name.regional[0].regional_domain_name, "") : try(aws_api_gateway_domain_name.edge[0].cloudfront_domain_name, "")
}
