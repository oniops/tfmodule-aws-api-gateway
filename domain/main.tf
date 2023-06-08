locals {
  name_prefix           = var.context.name_prefix
  tags                  = var.context.tags
  nlb_name              = format("%s-openapi-nlb", local.name_prefix)
  vpc_link_name         = format("%s-openapi", local.name_prefix)
  domain_name           = format("%s.%s", var.public_domain_prefix, var.context.domain)
  create_route53_record = var.exists_public_hosting_zone
}

resource "aws_api_gateway_domain_name" "regional" {
  count                    = var.endpoint_type == "REGIONAL" ? 1 : 0
  regional_certificate_arn = data.aws_acm_certificate.this.arn
  domain_name              = local.domain_name

  endpoint_configuration {
    types = [var.endpoint_type]
  }

  tags = merge(local.tags,
    { Name = local.domain_name }
  )
}

resource "aws_route53_record" "regional" {
  count   = local.create_route53_record && var.endpoint_type == "REGIONAL" ? 1 : 0
  name    = concat(aws_api_gateway_domain_name.regional.*.domain_name, [""])[0]
  type    = "A"
  zone_id = concat(data.aws_route53_zone.public.*.zone_id, [""])[0]

  alias {
    evaluate_target_health = true
    name                   = concat(aws_api_gateway_domain_name.regional.*.regional_domain_name, [""])[0]
    zone_id                = concat(aws_api_gateway_domain_name.regional.*.regional_zone_id, [""])[0]
  }
}

resource "aws_api_gateway_domain_name" "edge" {
  count           = var.endpoint_type == "EDGE" ? 1 : 0
  certificate_arn = data.aws_acm_certificate.this.arn
  domain_name     = local.domain_name

  endpoint_configuration {
    types = [var.endpoint_type]
  }

  tags = merge(local.tags,
    { Name = local.domain_name }
  )
}

resource "aws_route53_record" "edge" {
  count   = local.create_route53_record && var.endpoint_type == "EDGE" ? 1 : 0
  name    = concat(aws_api_gateway_domain_name.edge.*.domain_name, [""])[0]
  type    = "A"
  zone_id = concat(data.aws_route53_zone.public.*.zone_id, [""])[0]

  alias {
    evaluate_target_health = true
    name                   = concat(aws_api_gateway_domain_name.edge.*.cloudfront_domain_name, [""])[0]
    zone_id                = concat(aws_api_gateway_domain_name.edge.*.cloudfront_zone_id, [""])[0]
  }
}
