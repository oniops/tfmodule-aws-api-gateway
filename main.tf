locals {
  api_gw_name = format("%s-%s-api", var.context.name_prefix, var.api_name)
  role_name   = format("%s%s", var.context.project, replace(title( format("%s-APIGatewayLoggingRole", var.api_name) ), "-", "" ))
  policy_name = format("%s%s", var.context.project, replace(title( format("%s-APIGatewayLoggingPolicy", var.api_name) ), "-", "" ))
  description = var.description == null ? format("%s RestAPI Gateway", local.api_gw_name) : var.description
}

resource "aws_api_gateway_rest_api" "this" {
  count = var.create_api_gateway ? 1 : 0

  name        = local.api_gw_name
  description = local.description
  tags        = merge( var.context.tags, { Name = local.api_gw_name })
  #    endpoint_configuration {
  #      types = [var.endpoint_type]
  #    }
}

resource "aws_iam_role" "apigw" {
  name               = local.role_name
  description        = "Serverless Architecture on AWS role for api gateway to access cloud watch"
  assume_role_policy = data.aws_iam_policy_document.assume_apigw.json
  tags               = merge(var.context.tags,
    { Name = local.role_name }
  )
}

resource "aws_iam_role_policy_attachment" "apigw_logging" {
  role       = aws_iam_role.apigw.id
  policy_arn = data.aws_iam_policy.apigw_cw.arn
}

resource "aws_iam_role_policy" "apigw_logging" {
  name = local.policy_name
  role = aws_iam_role.apigw.id

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
  cloudwatch_role_arn = aws_iam_role.apigw.arn
  depends_on          = [
    aws_iam_role_policy_attachment.apigw_logging,
    aws_iam_role_policy.apigw_logging
  ]
}
