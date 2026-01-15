output "cloudtrail_info" {
  description = "CloudTrail configuration details"
  value = {
    trail_name     = module.cloudtrail.trail_name
    trail_arn      = module.cloudtrail.trail_arn
    s3_bucket_name = module.cloudtrail.s3_bucket_name
  }
}

output "vpc_flow_logs_info" {
  description = "VPC Flow Logs configuration details"
  value = {
    log_group_name = module.vpc_flow_logs.log_group_name
    enabled_vpcs   = module.vpc_flow_logs.enabled_vpc_count
  }
}

output "iam_password_policy" {
  description = "IAM password policy settings"
  value       = module.iam_password_policy.password_policy
}

output "s3_encryption_info" {
  description = "S3 encryption configuration details"
  value = {
    encrypted_bucket_count = module.s3_encryption.encrypted_bucket_count
    encrypted_buckets      = module.s3_encryption.encrypted_buckets
  }
}
