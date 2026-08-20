data "aws_acm_certificate" "this" {
  domain      = coalesce(var.domain, var.context.domain)
  statuses    = ["ISSUED"]
  most_recent = true
}

data "aws_route53_zone" "public" {
  count = local.create_route53_record ? 1 : 0
  name  = coalesce(var.domain, var.context.domain)
}
