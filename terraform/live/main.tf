terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment and configure for remote state
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "compliance/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
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

# Enable CloudTrail logging
module "cloudtrail" {
  source = "../modules/cloudtrail"

  trail_name     = var.cloudtrail_name
  s3_bucket_name = var.cloudtrail_bucket_name

  tags = {
    Component = "CloudTrail"
  }
}

# Enable VPC Flow Logs
module "vpc_flow_logs" {
  source = "../modules/vpc-flow-logs"

  retention_days = var.flow_logs_retention_days
  traffic_type   = "ALL"

  tags = {
    Component = "VPC-Flow-Logs"
  }
}

# Set IAM password policy
module "iam_password_policy" {
  source = "../modules/iam-password-policy"

  minimum_password_length      = 14
  require_lowercase_characters = true
  require_uppercase_characters = true
  require_numbers              = true
  require_symbols              = true
  max_password_age             = 90
  password_reuse_prevention    = 24
}

# Enable S3 bucket encryption
module "s3_encryption" {
  source = "../modules/s3-encryption"

  sse_algorithm = "AES256"
}
