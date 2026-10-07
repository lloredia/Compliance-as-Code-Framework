data "aws_s3_buckets" "all" {
  count = var.manage_existing_buckets ? 1 : 0
}

locals {
  discovered = var.manage_existing_buckets ? data.aws_s3_buckets.all[0].buckets : []
  managed_buckets = toset([
    for name in local.discovered : name
    if length([
      for prefix in var.exclude_bucket_prefixes : prefix
      if startswith(name, prefix)
    ]) == 0
  ])
}

resource "aws_s3_account_public_access_block" "this" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

module "encryption_key" {
  count  = var.manage_existing_buckets ? 1 : 0
  source = "../cmk"

  name               = "s3-existing-bucket-encryption"
  description        = "Default encryption key for pre-existing S3 buckets."
  service_principals = ["s3.amazonaws.com"]
  tags               = var.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "existing" {
  for_each = local.managed_buckets

  bucket = each.value

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = module.encryption_key[0].key_arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "existing" {
  for_each = local.managed_buckets

  bucket = each.value

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
