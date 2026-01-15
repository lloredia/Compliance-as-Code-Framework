# S3 Encryption Module - Enables default encryption on all S3 buckets
data "aws_s3_buckets" "all" {}

data "aws_s3_bucket" "existing" {
  for_each = toset(data.aws_s3_buckets.all.buckets)
  bucket   = each.value
}

# Enable default encryption for all existing buckets
resource "aws_s3_bucket_server_side_encryption_configuration" "existing_buckets" {
  for_each = data.aws_s3_bucket.existing

  bucket = each.value.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.sse_algorithm
      kms_master_key_id = var.sse_algorithm == "aws:kms" ? var.kms_master_key_id : null
    }
    bucket_key_enabled = var.bucket_key_enabled
  }
}

# Enable versioning for all buckets (best practice with encryption)
resource "aws_s3_bucket_versioning" "existing_buckets" {
  for_each = data.aws_s3_bucket.existing

  bucket = each.value.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Block public access for all buckets
resource "aws_s3_bucket_public_access_block" "existing_buckets" {
  for_each = data.aws_s3_bucket.existing

  bucket = each.value.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
