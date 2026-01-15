variable "minimum_password_length" {
  description = "Minimum length of password (CIS recommends 14)"
  type        = number
  default     = 14
}

variable "require_lowercase_characters" {
  description = "Require at least one lowercase letter"
  type        = bool
  default     = true
}

variable "require_uppercase_characters" {
  description = "Require at least one uppercase letter"
  type        = bool
  default     = true
}

variable "require_numbers" {
  description = "Require at least one number"
  type        = bool
  default     = true
}

variable "require_symbols" {
  description = "Require at least one symbol"
  type        = bool
  default     = true
}

variable "allow_users_to_change_password" {
  description = "Allow users to change their own password"
  type        = bool
  default     = true
}

variable "max_password_age" {
  description = "Maximum age of password in days (CIS recommends 90)"
  type        = number
  default     = 90
}

variable "password_reuse_prevention" {
  description = "Number of previous passwords to prevent reuse (CIS recommends 24)"
  type        = number
  default     = 24
}

variable "hard_expiry" {
  description = "Prevent users from resetting expired passwords themselves"
  type        = bool
  default     = false
}
