variable "enable_per_vpc" {
  description = "Enable flow logs for all VPCs in the account"
  type        = bool
  default     = true
}

variable "traffic_type" {
  description = "Type of traffic to log (ACCEPT, REJECT, or ALL)"
  type        = string
  default     = "ALL"

  validation {
    condition     = contains(["ACCEPT", "REJECT", "ALL"], var.traffic_type)
    error_message = "Traffic type must be ACCEPT, REJECT, or ALL."
  }
}

variable "log_retention_days" {
  description = "Number of days to retain flow logs in CloudWatch"
  type        = number
  default     = 30
}

variable "role_name_prefix" {
  description = "Prefix for IAM role name"
  type        = string
  default     = "compliance"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
