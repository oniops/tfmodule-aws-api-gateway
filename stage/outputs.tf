output "cloudwatch_log_group_name" {
  value = try(aws_cloudwatch_log_group.this.*.name, "")
}

output "cloudwatch_log_group_arn" {
  value = concat(aws_cloudwatch_log_group.this.*.arn, [""])[0]
}
