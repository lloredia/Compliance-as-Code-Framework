package main

import rego.v1

write(address, type, after) := {
	"address": address,
	"mode": "managed",
	"type": type,
	"change": {"actions": ["create"], "after": after},
}

plan(changes) := {"resource_changes": changes}

test_allows_private_https if {
	count(deny) == 0 with input as plan([write("aws_security_group_rule.https", "aws_security_group_rule", {
		"from_port": 443, "to_port": 443, "cidr_blocks": ["10.0.0.0/16"], "ipv6_cidr_blocks": [],
	})])
}

test_denies_open_ssh_rule if {
	result := deny with input as plan([write("aws_security_group_rule.ssh", "aws_security_group_rule", {
		"from_port": 22, "to_port": 22, "cidr_blocks": ["0.0.0.0/0"], "ipv6_cidr_blocks": [],
	})])
	count(result) == 1
}

test_denies_open_rdp_ipv6 if {
	result := deny with input as plan([write("aws_security_group_rule.rdp", "aws_security_group_rule", {
		"from_port": 3389, "to_port": 3389, "cidr_blocks": [], "ipv6_cidr_blocks": ["::/0"],
	})])
	count(result) == 1
}

test_denies_inline_ingress if {
	result := deny with input as plan([write("aws_security_group.web", "aws_security_group", {
		"ingress": [{"from_port": 22, "to_port": 22, "cidr_blocks": ["0.0.0.0/0"], "ipv6_cidr_blocks": []}],
	})])
	count(result) == 1
}

test_denies_vpc_ingress_rule if {
	result := deny with input as plan([write("aws_vpc_security_group_ingress_rule.ssh", "aws_vpc_security_group_ingress_rule", {
		"from_port": 22, "to_port": 22, "cidr_ipv4": "0.0.0.0/0",
	})])
	count(result) == 1
}

test_denies_disabled_public_access_block if {
	result := deny with input as plan([write("aws_s3_bucket_public_access_block.logs", "aws_s3_bucket_public_access_block", {
		"block_public_acls": true,
		"block_public_policy": false,
		"ignore_public_acls": true,
		"restrict_public_buckets": true,
	})])
	count(result) == 1
}

test_allows_account_public_access_block if {
	count(deny) == 0 with input as plan([write("aws_s3_account_public_access_block.this", "aws_s3_account_public_access_block", {
		"block_public_acls": true,
		"block_public_policy": true,
		"ignore_public_acls": true,
		"restrict_public_buckets": true,
	})])
}

test_denies_single_region_trail if {
	result := deny with input as plan([write("aws_cloudtrail.main", "aws_cloudtrail", {
		"is_multi_region_trail": false,
		"enable_log_file_validation": true,
	})])
	count(result) == 1
}

test_denies_trail_without_validation if {
	result := deny with input as plan([write("aws_cloudtrail.main", "aws_cloudtrail", {
		"is_multi_region_trail": true,
		"enable_log_file_validation": false,
	})])
	count(result) == 1
}

test_allows_compliant_trail if {
	count(deny) == 0 with input as plan([write("aws_cloudtrail.main", "aws_cloudtrail", {
		"is_multi_region_trail": true,
		"enable_log_file_validation": true,
	})])
}

test_ignores_destroy if {
	change := write("aws_security_group_rule.ssh", "aws_security_group_rule", {
		"from_port": 22, "to_port": 22, "cidr_blocks": ["0.0.0.0/0"],
	})
	destroy := object.union(change, {"change": {"actions": ["delete"], "after": change.change.after}})
	count(deny) == 0 with input as plan([destroy])
}
