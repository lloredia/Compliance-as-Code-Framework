variable "trail_name" {
  description = "Name of the multi-region CloudTrail trail."
  type        = string
  default     = "compliance-trail"
}

variable "bucket_name" {
  description = "Name of the S3 bucket for CloudTrail logs. Must be globally unique and at most 56 characters."
  type        = string
}

variable "log_retention_days" {
  description = "Retention in days for CloudTrail objects and the CloudWatch log group."
  type        = number
  default     = 365

  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653
    ], var.log_retention_days)
    error_message = "log_retention_days must be a CloudWatch Logs retention value."
  }
}

variable "force_destroy" {
  description = "Allow Terraform to destroy the CloudTrail buckets when they still contain objects."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to CloudTrail resources."
  type        = map(string)
  default     = {}
}
