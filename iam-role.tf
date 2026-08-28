locals {
  role_name = "${var.context.project}APIGatewayLoggingRole"
}

resource "aws_iam_role" "apigw" {
  count              = var.create_api_account ? 1 : 0
  name               = local.role_name
  description        = "Serverless Architecture on AWS role for api gateway to access cloud watch"
  assume_role_policy = data.aws_iam_policy_document.assume_apigw[0].json
  tags               = merge(var.context.tags, { Name = local.role_name })
}

resource "aws_iam_role_policy_attachment" "apigw_logging" {
  count      = var.create_api_account ? 1 : 0
  role       = aws_iam_role.apigw[0].id
  policy_arn = data.aws_iam_policy.apigw_cw[0].arn
}

resource "aws_api_gateway_account" "apigw_account" {
  count               = var.create_api_account ? 1 : 0
  cloudwatch_role_arn = aws_iam_role.apigw[0].arn
  depends_on = [
    aws_iam_role_policy_attachment.apigw_logging,
  ]
}
