output "policy_details" {
  description = "Details of the IAM password policy"
  value = {
    minimum_password_length      = aws_iam_account_password_policy.strict.minimum_password_length
    max_password_age             = aws_iam_account_password_policy.strict.max_password_age
    password_reuse_prevention    = aws_iam_account_password_policy.strict.password_reuse_prevention
    require_lowercase_characters = aws_iam_account_password_policy.strict.require_lowercase_characters
    require_uppercase_characters = aws_iam_account_password_policy.strict.require_uppercase_characters
    require_numbers              = aws_iam_account_password_policy.strict.require_numbers
    require_symbols              = aws_iam_account_password_policy.strict.require_symbols
  }
}
