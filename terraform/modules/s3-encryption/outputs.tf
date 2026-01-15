output "encrypted_buckets" {
  description = "List of bucket names with encryption enabled"
  value       = [for k, v in aws_s3_bucket_server_side_encryption_configuration.existing_buckets : v.bucket]
}

output "encrypted_bucket_count" {
  description = "Number of buckets with encryption enabled"
  value       = length(aws_s3_bucket_server_side_encryption_configuration.existing_buckets)
}
