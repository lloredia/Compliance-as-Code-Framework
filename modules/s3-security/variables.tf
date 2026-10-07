variable "bucket_names" {
  description = "Pre-existing bucket names to encrypt with a customer managed key and block public access. Leave empty to set only the account-level public access block. The AWS provider cannot list every bucket, so names are explicit."
  type        = list(string)
  default     = []
}

variable "exclude_bucket_prefixes" {
  description = "Bucket name prefixes skipped even when present in bucket_names."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to the KMS key used for existing-bucket encryption."
  type        = map(string)
  default     = {}
}
