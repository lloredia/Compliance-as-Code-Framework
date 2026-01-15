terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Optional: Configure backend for state storage
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "compliance/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

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

# Module 1: Enable CloudTrail
module "cloudtrail" {
  source = "../modules/cloudtrail"

  trail_name         = "${var.project_name}-trail"
  bucket_name        = "${lower(var.project_name)}-cloudtrail-${data.aws_caller_identity.current.account_id}"
  log_retention_days = var.cloudtrail_retention_days

  tags = var.tags
}

# Module 2: Enable VPC Flow Logs
module "vpc_flow_logs" {
  source = "../modules/vpc-flow-logs"

  enable_per_vpc     = true
  traffic_type       = "ALL"
  log_retention_days = var.flowlog_retention_days

  tags = var.tags
}

# Module 3: IAM Password Policy
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

# Data source to get current AWS account ID
data "aws_caller_identity" "current" {}
