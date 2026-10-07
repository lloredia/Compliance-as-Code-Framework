provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "Compliance-as-Code"
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  }
}

data "aws_caller_identity" "current" {}

locals {
  name_prefix = lower(var.project_name)
}

module "cloudtrail" {
  source = "../modules/cloudtrail"

  trail_name         = "${local.name_prefix}-trail"
  bucket_name        = "${local.name_prefix}-cloudtrail-${data.aws_caller_identity.current.account_id}"
  log_retention_days = var.cloudtrail_retention_days
  tags               = var.tags
}

module "vpc_flow_logs" {
  source = "../modules/vpc-flow-logs"

  enable_per_vpc     = true
  traffic_type       = "ALL"
  log_retention_days = var.flowlog_retention_days
  role_name_prefix   = local.name_prefix
  tags               = var.tags
}

module "iam_password_policy" {
  source = "../modules/iam-password-policy"

  minimum_password_length      = 14
  max_password_age             = 90
  password_reuse_prevention    = 24
  require_lowercase_characters = true
  require_uppercase_characters = true
  require_numbers              = true
  require_symbols              = true
}

module "s3_security" {
  source = "../modules/s3-security"

  bucket_names            = var.existing_s3_bucket_names
  exclude_bucket_prefixes = [local.name_prefix]
  tags                    = var.tags
}

module "aws_config" {
  source = "../modules/aws-config"

  name_prefix = local.name_prefix
  bucket_name = "${local.name_prefix}-config-${data.aws_caller_identity.current.account_id}"
  tags        = var.tags
}

module "security_group_audit" {
  source = "../modules/security-group-audit"

  name_prefix = local.name_prefix

  depends_on = [module.aws_config]
}

module "cloudwatch_cis_alarms" {
  source = "../modules/cloudwatch-cis-alarms"

  name_prefix               = local.name_prefix
  cloudtrail_log_group_name = module.cloudtrail.cloudwatch_log_group_name
  notification_email        = var.notification_email
  tags                      = var.tags
}
