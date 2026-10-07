variable "name" {
  description = "KMS alias name without the alias/ prefix."
  type        = string
}

variable "description" {
  description = "Description stored on the customer managed key."
  type        = string
}

variable "service_principals" {
  description = "AWS service principals allowed to use the key."
  type        = list(string)
  default     = []
}

variable "additional_policy_json" {
  description = "Optional complete IAM policy JSON merged into the key policy."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to the key."
  type        = map(string)
  default     = {}
}
