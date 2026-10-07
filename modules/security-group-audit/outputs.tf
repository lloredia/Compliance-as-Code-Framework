output "restricted_ssh_rule_name" {
  description = "Name of the restricted-ssh AWS Config rule."
  value       = aws_config_config_rule.restricted_ssh.name
}

output "restricted_common_ports_rule_name" {
  description = "Name of the restricted-common-ports AWS Config rule."
  value       = aws_config_config_rule.restricted_common_ports.name
}
