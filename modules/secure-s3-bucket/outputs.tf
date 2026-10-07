output "bucket_id" {
  description = "Name of the primary bucket."
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "ARN of the primary bucket."
  value       = aws_s3_bucket.this.arn
}

output "access_log_bucket_id" {
  description = "Name of the access-log bucket."
  value       = aws_s3_bucket.access_logs.id
}

output "access_log_bucket_arn" {
  description = "ARN of the access-log bucket."
  value       = aws_s3_bucket.access_logs.arn
}
