variable "manage_existing_buckets" {
  description = "Apply default KMS encryption and Block Public Access to buckets already in the account. Buckets created by this stack should be listed in exclude_bucket_prefixes so they are not managed twice."
  type        = bool
  default     = false
}

variable "exclude_bucket_prefixes" {
  description = "Bucket name prefixes skipped when manage_existing_buckets is true."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to the KMS key used for existing-bucket encryption."
  type        = map(string)
  default     = {}
}
