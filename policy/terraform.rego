package main

import rego.v1

admin_ports := {22, 3389}

public_access_block_types := {
	"aws_s3_bucket_public_access_block",
	"aws_s3_account_public_access_block",
}

public_access_flags := [
	"block_public_acls",
	"block_public_policy",
	"ignore_public_acls",
	"restrict_public_buckets",
]

is_write(change) if {
	some action in object.get(object.get(change, "change", {}), "actions", [])
	action in {"create", "update"}
}

internet(cidr) if cidr == "0.0.0.0/0"

internet(cidr) if cidr == "::/0"

exposes_admin_port(rule) if {
	object.get(rule, "protocol", "tcp") == "-1"
	some cidr in object.get(rule, "cidr_blocks", [])
	internet(cidr)
}

exposes_admin_port(rule) if {
	some port in admin_ports
	object.get(rule, "from_port", -1) <= port
	object.get(rule, "to_port", -1) >= port
	some cidr in object.get(rule, "cidr_blocks", [])
	internet(cidr)
}

exposes_admin_port(rule) if {
	some port in admin_ports
	object.get(rule, "from_port", -1) <= port
	object.get(rule, "to_port", -1) >= port
	some cidr in object.get(rule, "ipv6_cidr_blocks", [])
	internet(cidr)
}

deny contains msg if {
	some change in object.get(input, "resource_changes", [])
	is_write(change)
	change.type == "aws_security_group_rule"
	after := object.get(change.change, "after", {})
	exposes_admin_port(after)
	msg := sprintf("%s opens SSH or RDP to the internet", [change.address])
}

deny contains msg if {
	some change in object.get(input, "resource_changes", [])
	is_write(change)
	change.type == "aws_security_group"
	after := object.get(change.change, "after", {})
	some rule in object.get(after, "ingress", [])
	exposes_admin_port(rule)
	msg := sprintf("%s opens SSH or RDP to the internet", [change.address])
}

deny contains msg if {
	some change in object.get(input, "resource_changes", [])
	is_write(change)
	change.type == "aws_vpc_security_group_ingress_rule"
	after := object.get(change.change, "after", {})
	internet(object.get(after, "cidr_ipv4", ""))
	some port in admin_ports
	object.get(after, "from_port", -1) <= port
	object.get(after, "to_port", -1) >= port
	msg := sprintf("%s opens SSH or RDP to the internet", [change.address])
}

deny contains msg if {
	some change in object.get(input, "resource_changes", [])
	is_write(change)
	change.type in public_access_block_types
	after := object.get(change.change, "after", {})
	some flag in public_access_flags
	object.get(after, flag, false) != true
	msg := sprintf("%s must set %s to true", [change.address, flag])
}

deny contains msg if {
	some change in object.get(input, "resource_changes", [])
	is_write(change)
	change.type == "aws_cloudtrail"
	after := object.get(change.change, "after", {})
	object.get(after, "is_multi_region_trail", false) != true
	msg := sprintf("%s must be a multi-region trail", [change.address])
}

deny contains msg if {
	some change in object.get(input, "resource_changes", [])
	is_write(change)
	change.type == "aws_cloudtrail"
	after := object.get(change.change, "after", {})
	object.get(after, "enable_log_file_validation", false) != true
	msg := sprintf("%s must enable log file validation", [change.address])
}
