variable "aws_region" {
  description = "AWS region for regional resources such as the Config recorder and CloudWatch alarms."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Prefix for resource names. Also excluded from the optional existing-bucket encryption pass."
  type        = string
  default     = "compliance"
}

variable "cloudtrail_retention_days" {
  description = "CloudTrail log retention in days."
  type        = number
  default     = 365
}

variable "flowlog_retention_days" {
  description = "VPC Flow Logs retention in days. The baseline keeps a year so the log groups meet the one-year retention check."
  type        = number
  default     = 365
}

variable "existing_s3_bucket_names" {
  description = "Pre-existing S3 bucket names to encrypt and block public access on. Leave empty to set only the account-level public access block."
  type        = list(string)
  default     = []
}

variable "notification_email" {
  description = "Optional email subscribed to CIS CloudWatch alarms. Leave empty to create the topic without a subscription."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags applied to supported resources."
  type        = map(string)
  default     = {}
}
