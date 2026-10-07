variable "bucket_name" {
  description = "Globally unique bucket name. Keep it to 56 characters or fewer so the access-log bucket name fits."
  type        = string
}

variable "kms_key_arn" {
  description = "Customer managed key ARN used for default bucket encryption."
  type        = string
}

variable "expiration_days" {
  description = "Object expiration in days. Transitions are added only when this is long enough."
  type        = number
  default     = 365
}

variable "force_destroy" {
  description = "Delete bucket objects on destroy. Leave false outside disposable environments."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to the bucket and its access-log bucket."
  type        = map(string)
  default     = {}
}
