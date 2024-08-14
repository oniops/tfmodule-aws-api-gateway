resource "aws_cloudwatch_log_group" "this" {
  count             = local.create && var.enable_access_logs ? 1 : 0
  name              = local.cloudwatch_log_group_name
  retention_in_days = var.retention_in_days
  lifecycle {
    create_before_destroy = true
  }
}
