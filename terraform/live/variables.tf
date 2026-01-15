variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "cloudtrail_name" {
  description = "Name of the CloudTrail trail"
  type        = string
  default     = "organization-security-trail"
}

variable "cloudtrail_bucket_name" {
  description = "S3 bucket name for CloudTrail logs (must be globally unique)"
  type        = string
  # You'll need to customize this with your account ID or a unique suffix
  default = "cloudtrail-logs-952995844826"
}

variable "flow_logs_retention_days" {
  description = "Number of days to retain VPC flow logs"
  type        = number
  default     = 30
}
