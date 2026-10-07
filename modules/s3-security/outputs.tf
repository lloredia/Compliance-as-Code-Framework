output "account_public_access_block_id" {
  description = "Account ID recorded on the account-level S3 Block Public Access configuration."
  value       = aws_s3_account_public_access_block.this.id
}

output "managed_bucket_count" {
  description = "Number of pre-existing buckets this module encrypts and locks down."
  value       = length(local.managed_buckets)
}

output "managed_buckets" {
  description = "Names of pre-existing buckets this module manages."
  value       = sort(tolist(local.managed_buckets))
}
