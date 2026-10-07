output "cloudtrail_arn" {
  description = "ARN of the CloudTrail trail."
  value       = aws_cloudtrail.main.arn
}

output "cloudtrail_name" {
  description = "Name of the CloudTrail trail."
  value       = aws_cloudtrail.main.name
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket storing CloudTrail logs."
  value       = module.logs.bucket_id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket storing CloudTrail logs."
  value       = module.logs.bucket_arn
}

output "access_log_bucket_name" {
  description = "Name of the access-log bucket for the CloudTrail bucket."
  value       = module.logs.access_log_bucket_id
}

output "cloudwatch_log_group_name" {
  description = "CloudWatch log group that receives CloudTrail events."
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "sns_topic_arn" {
  description = "SNS topic that receives CloudTrail delivery notifications."
  value       = aws_sns_topic.cloudtrail.arn
}

output "kms_key_arn" {
  description = "KMS key that encrypts CloudTrail data."
  value       = module.kms.key_arn
}
