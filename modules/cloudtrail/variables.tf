variable "trail_name" {
  description = "Name of the CloudTrail trail"
  type        = string
  default     = "compliance-trail"
}

variable "bucket_name" {
  description = "Name of the S3 bucket for CloudTrail logs (must be globally unique)"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain CloudTrail logs"
  type        = number
  default     = 365
}

variable "force_destroy" {
  description = "Allow destruction of S3 bucket even if it contains objects"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
