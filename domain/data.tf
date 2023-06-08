data "aws_acm_certificate" "this" {
  domain = var.context.domain
}

data "aws_route53_zone" "public" {
  count = local.create_route53_record ? 1 : 0
  name  = var.context.domain
}
