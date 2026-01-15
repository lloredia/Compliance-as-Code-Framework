output "flow_log_ids" {
  description = "Map of VPC IDs to Flow Log IDs"
  value       = { for k, v in aws_flow_log.main : k => v.id }
}

output "log_group_names" {
  description = "Map of VPC IDs to CloudWatch Log Group names"
  value       = { for k, v in aws_cloudwatch_log_group.flow_logs : k => v.name }
}

output "iam_role_arn" {
  description = "ARN of the IAM role used by Flow Logs"
  value       = var.enable_per_vpc ? aws_iam_role.flow_logs[0].arn : null
}
