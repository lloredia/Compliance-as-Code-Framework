data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "access_logs" {
  # This bucket is the access-log destination for the primary bucket.
  #checkov:skip=CKV_AWS_18:Access-log buckets do not ship logs to a second bucket.
  #checkov:skip=CKV_AWS_144:Cross-region replication is intentionally out of scope for this single-region baseline.
  #checkov:skip=CKV2_AWS_62:Access logs are read from the bucket; event notifications are not required.
  bucket        = "${var.bucket_name}-access"
  force_destroy = var.force_destroy

  tags = merge(var.tags, {
    Purpose = "s3-access-logs"
  })
}

resource "aws_s3_bucket_versioning" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  rule {
    id     = "expire-access-logs"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    expiration {
      days = var.expiration_days
    }
  }
}

data "aws_iam_policy_document" "access_logs" {
  statement {
    sid    = "S3ServerAccessLogs"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.access_logs.arn}/access/*"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }

  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.access_logs.arn,
      "${aws_s3_bucket.access_logs.arn}/*",
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id
  policy = data.aws_iam_policy_document.access_logs.json
}

resource "aws_s3_bucket" "this" {
  #checkov:skip=CKV_AWS_144:Cross-region replication is intentionally out of scope for this single-region baseline.
  #checkov:skip=CKV2_AWS_62:Delivery buckets are consumed by the owning AWS service, not by event notifications.
  bucket        = var.bucket_name
  force_destroy = var.force_destroy

  tags = var.tags
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_logging" "this" {
  bucket        = aws_s3_bucket.this.id
  target_bucket = aws_s3_bucket.access_logs.id
  target_prefix = "access/"
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "expire-objects"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    dynamic "transition" {
      for_each = var.expiration_days > 90 ? [90] : []
      content {
        days          = transition.value
        storage_class = "STANDARD_IA"
      }
    }

    dynamic "transition" {
      for_each = var.expiration_days > 180 ? [180] : []
      content {
        days          = transition.value
        storage_class = "GLACIER"
      }
    }

    expiration {
      days = var.expiration_days
    }
  }
}
