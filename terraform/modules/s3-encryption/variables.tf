variable "sse_algorithm" {
  description = "Server-side encryption algorithm (AES256 or aws:kms)"
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "aws:kms"], var.sse_algorithm)
    error_message = "SSE algorithm must be AES256 or aws:kms."
  }
}

variable "kms_master_key_id" {
  description = "KMS key ID (required if sse_algorithm is aws:kms)"
  type        = string
  default     = null
}

variable "bucket_key_enabled" {
  description = "Enable S3 Bucket Key for reducing KMS costs"
  type        = bool
  default     = true
}
