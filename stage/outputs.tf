output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group for stage access logs. Returns an empty value when enable_access_logs is false."
  value       = try(aws_cloudwatch_log_group.this.*.name, "")
}

output "cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch log group for stage access logs. Returns an empty string when enable_access_logs is false."
  value       = concat(aws_cloudwatch_log_group.this.*.arn, [""])[0]
}

output "name" {
  description = "The name of the deployed stage."
  value       = var.name
}
