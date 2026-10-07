variable "name_prefix" {
  description = "Prefix for the recorder, delivery channel, and conformance pack."
  type        = string
  default     = "compliance"
}

variable "bucket_name" {
  description = "Globally unique name for the AWS Config delivery bucket."
  type        = string
}

variable "enable_conformance_pack" {
  description = "Deploy the CIS-aligned AWS Config conformance pack."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to Config resources."
  type        = map(string)
  default     = {}
}
