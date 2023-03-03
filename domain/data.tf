data "aws_acm_certificate" "this" {
  domain = var.context.domain
}

data "aws_route53_zone" "public" {
  name = var.context.domain
}
