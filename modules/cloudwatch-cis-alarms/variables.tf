variable "name_prefix" {
  description = "Prefix for alarm and topic names."
  type        = string
  default     = "compliance"
}

variable "cloudtrail_log_group_name" {
  description = "CloudWatch log group that receives CloudTrail management events."
  type        = string
}

variable "notification_email" {
  description = "Optional email address subscribed to the alarm topic. Leave empty to skip the subscription."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags applied to the alarm topic and KMS key."
  type        = map(string)
  default     = {}
}
