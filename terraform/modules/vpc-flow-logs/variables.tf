variable "retention_days" {
  description = "Number of days to retain flow logs in CloudWatch"
  type        = number
  default     = 30
}

variable "traffic_type" {
  description = "Type of traffic to log (ALL, ACCEPT, or REJECT)"
  type        = string
  default     = "ALL"

  validation {
    condition     = contains(["ALL", "ACCEPT", "REJECT"], var.traffic_type)
    error_message = "Traffic type must be ALL, ACCEPT, or REJECT."
  }
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
