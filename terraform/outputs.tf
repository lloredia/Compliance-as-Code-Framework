output "cloudtrail_info" {
  description = "CloudTrail configuration details."
  value = {
    trail_arn          = module.cloudtrail.cloudtrail_arn
    trail_name         = module.cloudtrail.cloudtrail_name
    s3_bucket          = module.cloudtrail.s3_bucket_name
    cloudwatch_logs    = module.cloudtrail.cloudwatch_log_group_name
    notification_topic = module.cloudtrail.sns_topic_arn
  }
}

output "vpc_flow_logs_info" {
  description = "VPC Flow Logs configuration details."
  value = {
    flow_log_ids    = module.vpc_flow_logs.flow_log_ids
    log_group_names = module.vpc_flow_logs.log_group_names
    iam_role_arn    = module.vpc_flow_logs.iam_role_arn
  }
}

output "iam_password_policy" {
  description = "IAM password policy details."
  value       = module.iam_password_policy.policy_details
}

output "s3_security" {
  description = "Account-level S3 public access block and optional existing-bucket coverage."
  value = {
    account_public_access_block_id = module.s3_security.account_public_access_block_id
    managed_bucket_count           = module.s3_security.managed_bucket_count
  }
}

output "aws_config" {
  description = "AWS Config recorder and CIS-aligned conformance pack."
  value = {
    recorder_name           = module.aws_config.recorder_name
    bucket_name             = module.aws_config.bucket_name
    conformance_pack_name   = module.aws_config.conformance_pack_name
    restricted_ssh          = module.security_group_audit.restricted_ssh_rule_name
    restricted_common_ports = module.security_group_audit.restricted_common_ports_rule_name
  }
}

output "cis_alarm_topic_arn" {
  description = "SNS topic for CIS 4.1-4.15 CloudWatch alarms."
  value       = module.cloudwatch_cis_alarms.sns_topic_arn
}
