data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  trail_arn = "arn:aws:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/${var.trail_name}"
}

module "kms" {
  source = "../cmk"

  name        = "${var.trail_name}-logs"
  description = "Encrypts the CloudTrail trail, log bucket, CloudWatch log group, and notification topic."
  tags        = var.tags
  additional_policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudTrailEncrypt"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action = [
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
        ]
        Resource = "*"
        Condition = {
          StringLike = {
            "kms:EncryptionContext:aws:cloudtrail:arn" = "arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"
          }
        }
      },
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Principal = {
          Service = "logs.${data.aws_region.current.name}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*",
        ]
        Resource = "*"
        Condition = {
          ArnLike = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*"
          }
        }
      },
      {
        Sid    = "SNS"
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey*",
        ]
        Resource = "*"
      },
    ]
  })
}

module "logs" {
  source = "../secure-s3-bucket"

  bucket_name     = var.bucket_name
  kms_key_arn     = module.kms.key_arn
  expiration_days = var.log_retention_days
  force_destroy   = var.force_destroy
  tags = merge(var.tags, {
    Purpose = "cloudtrail"
  })
}

data "aws_iam_policy_document" "bucket" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = [module.logs.bucket_arn]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [local.trail_arn]
    }
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["${module.logs.bucket_arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [local.trail_arn]
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
      module.logs.bucket_arn,
      "${module.logs.bucket_arn}/*",
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = module.logs.bucket_id
  policy = data.aws_iam_policy_document.bucket.json
}

resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/aws/cloudtrail/${var.trail_name}"
  retention_in_days = var.log_retention_days
  kms_key_id        = module.kms.key_arn

  tags = var.tags
}

data "aws_iam_policy_document" "cloudtrail_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cloudtrail" {
  name               = "${var.trail_name}-cloudwatch"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume.json

  tags = var.tags
}

data "aws_iam_policy_document" "cloudtrail_logs" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["${aws_cloudwatch_log_group.cloudtrail.arn}:*"]
  }
}

resource "aws_iam_role_policy" "cloudtrail" {
  name   = "cloudtrail-cloudwatch"
  role   = aws_iam_role.cloudtrail.id
  policy = data.aws_iam_policy_document.cloudtrail_logs.json
}

resource "aws_sns_topic" "cloudtrail" {
  name              = "${var.trail_name}-notifications"
  kms_master_key_id = module.kms.key_arn

  tags = var.tags
}

data "aws_iam_policy_document" "sns" {
  statement {
    sid    = "AWSCloudTrailSNS"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.cloudtrail.arn]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [local.trail_arn]
    }
  }
}

resource "aws_sns_topic_policy" "cloudtrail" {
  arn    = aws_sns_topic.cloudtrail.arn
  policy = data.aws_iam_policy_document.sns.json
}

resource "aws_cloudtrail" "main" {
  name                          = var.trail_name
  s3_bucket_name                = module.logs.bucket_id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  enable_logging                = true
  kms_key_id                    = module.kms.key_arn
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail.arn
  sns_topic_name                = aws_sns_topic.cloudtrail.name

  tags = var.tags

  depends_on = [
    aws_s3_bucket_policy.cloudtrail,
    aws_iam_role_policy.cloudtrail,
    aws_sns_topic_policy.cloudtrail,
  ]
}
