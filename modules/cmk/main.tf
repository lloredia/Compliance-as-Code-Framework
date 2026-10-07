data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "this" {
  # KMS key policies only accept Resource="*" and need an account-root admin statement.
  #checkov:skip=CKV_AWS_109:Account root must administer the CMK so the key cannot be orphaned.
  #checkov:skip=CKV_AWS_111:Account root must administer the CMK so the key cannot be orphaned.
  #checkov:skip=CKV_AWS_356:KMS key policies require Resource "*".

  source_policy_documents = var.additional_policy_json == null ? [] : [var.additional_policy_json]

  statement {
    sid = "AccountAdmin"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  dynamic "statement" {
    for_each = var.service_principals
    content {
      sid = "ServiceUse${statement.key}"
      principals {
        type        = "Service"
        identifiers = [statement.value]
      }
      actions = [
        "kms:Decrypt",
        "kms:DescribeKey",
        "kms:Encrypt",
        "kms:GenerateDataKey*",
        "kms:ReEncrypt*",
      ]
      resources = ["*"]
    }
  }
}

resource "aws_kms_key" "this" {
  # KMS key policies only accept Resource="*", and the account root must be able to administer the key.
  #checkov:skip=CKV_AWS_109:Account root administers this CMK so the key cannot be orphaned.
  #checkov:skip=CKV_AWS_111:Account root administers this CMK so the key cannot be orphaned.
  #checkov:skip=CKV_AWS_356:KMS key policies require Resource "*".
  description             = var.description
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.this.json

  tags = var.tags
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.name}"
  target_key_id = aws_kms_key.this.key_id
}
