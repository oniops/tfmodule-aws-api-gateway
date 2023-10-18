locals {
  role_name   = format("%sAPIGatewayLoggingRole", var.context.project)
  policy_name = format("%sAPIGatewayLoggingPolicy", var.context.project)
}

resource "aws_iam_role" "apigw" {
  count              = var.create_api_account ? 1 : 0
  name               = local.role_name
  description        = "Serverless Architecture on AWS role for api gateway to access cloud watch"
  assume_role_policy = data.aws_iam_policy_document.assume_apigw.json
  tags               = merge(var.context.tags, { Name = local.role_name }  )
}

resource "aws_iam_role_policy_attachment" "apigw_logging" {
  count      = var.create_api_account ? 1 : 0
  role       = try(aws_iam_role.apigw[0].id, "")
  policy_arn = data.aws_iam_policy.apigw_cw.arn
}

resource "aws_iam_role_policy" "apigw_logging" {
  count = var.create_api_account ? 1 : 0
  name  = local.policy_name
  role  = try(aws_iam_role.apigw[0].id, "")

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_api_gateway_account" "apigw_account" {
  count               = var.create_api_account ? 1 : 0
  cloudwatch_role_arn = try(aws_iam_role.apigw[0].arn, "")
  depends_on          = [
    aws_iam_role_policy_attachment.apigw_logging,
    aws_iam_role_policy.apigw_logging
  ]
}
