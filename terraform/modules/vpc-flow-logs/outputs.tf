output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.flow_logs.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.flow_logs.arn
}

output "flow_logs" {
  description = "Map of VPC IDs to flow log IDs"
  value       = { for k, v in aws_flow_log.vpc_flow_logs : k => v.id }
}

output "enabled_vpc_count" {
  description = "Number of VPCs with flow logs enabled"
  value       = length(aws_flow_log.vpc_flow_logs)
}
