locals {
  tags                  = var.context.tags
  domain_name           = "${var.public_domain_prefix}.${coalesce(var.domain, var.context.domain)}"
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
  name    = aws_api_gateway_domain_name.regional[0].domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.public[0].zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.regional[0].regional_domain_name
    zone_id                = aws_api_gateway_domain_name.regional[0].regional_zone_id
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
  name    = aws_api_gateway_domain_name.edge[0].domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.public[0].zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.edge[0].cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.edge[0].cloudfront_zone_id
  }
}
