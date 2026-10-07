data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

module "kms" {
  source = "../cmk"

  name        = "${var.name_prefix}-config"
  description = "Encrypts the AWS Config delivery bucket."
  tags        = var.tags
  additional_policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ConfigEncrypt"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
    ]
  })
}

module "bucket" {
  source = "../secure-s3-bucket"

  bucket_name = var.bucket_name
  kms_key_arn = module.kms.key_arn
  tags = merge(var.tags, {
    Purpose = "aws-config"
  })
}

data "aws_iam_policy_document" "bucket" {
  statement {
    sid    = "AWSConfigBucketPermissionsCheck"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = [module.bucket.bucket_arn]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }

  statement {
    sid    = "AWSConfigBucketDelivery"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["${module.bucket.bucket_arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/Config/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
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
      module.bucket.bucket_arn,
      "${module.bucket.bucket_arn}/*",
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "config" {
  bucket = module.bucket.bucket_id
  policy = data.aws_iam_policy_document.bucket.json
}

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "config" {
  name               = "${var.name_prefix}-config"
  assume_role_policy = data.aws_iam_policy_document.assume.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "config" {
  role       = aws_iam_role.config.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_config_configuration_recorder" "this" {
  name     = "${var.name_prefix}-recorder"
  role_arn = aws_iam_role.config.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }

  depends_on = [aws_iam_role_policy_attachment.config]
}

resource "aws_config_delivery_channel" "this" {
  name           = "${var.name_prefix}-channel"
  s3_bucket_name = module.bucket.bucket_id
  s3_key_prefix  = "config"
  s3_kms_key_arn = module.kms.key_arn

  depends_on = [aws_config_configuration_recorder.this]
}

resource "aws_config_configuration_recorder_status" "this" {
  name       = aws_config_configuration_recorder.this.name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.this]
}

resource "aws_config_conformance_pack" "cis" {
  count = var.enable_conformance_pack ? 1 : 0

  name          = "${var.name_prefix}-cis-aws-foundations"
  template_body = file("${path.module}/cis-conformance-pack.yaml")

  depends_on = [aws_config_configuration_recorder_status.this]
}
