output "cloudtrail_info" {
  description = "CloudTrail configuration details"
  value = {
    trail_arn  = module.cloudtrail.cloudtrail_arn
    trail_name = module.cloudtrail.cloudtrail_name
    s3_bucket  = module.cloudtrail.s3_bucket_name
  }
}

output "vpc_flow_logs_info" {
  description = "VPC Flow Logs configuration details"
  value = {
    flow_log_ids    = module.vpc_flow_logs.flow_log_ids
    log_group_names = module.vpc_flow_logs.log_group_names
    iam_role_arn    = module.vpc_flow_logs.iam_role_arn
  }
}

output "iam_password_policy" {
  description = "IAM password policy details"
  value       = module.iam_password_policy.policy_details
}

output "account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}
