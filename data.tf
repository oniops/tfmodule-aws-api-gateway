data "aws_iam_policy_document" "assume_apigw" {
  count = var.create_api_account ? 1 : 0

  statement {
    effect = "Allow"
    principals {
      identifiers = ["apigateway.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy" "apigw_cw" {
  count = var.create_api_account ? 1 : 0
  name  = "AmazonAPIGatewayPushToCloudWatchLogs"
}
