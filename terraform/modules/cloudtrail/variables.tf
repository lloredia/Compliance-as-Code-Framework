variable "trail_name" {
  description = "Name of the CloudTrail trail"
  type        = string
  default     = "organization-trail"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for CloudTrail logs (must be globally unique)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
