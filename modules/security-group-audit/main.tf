# CIS-aligned network exposure checks. Requires an AWS Config recorder in the region.
resource "aws_config_config_rule" "restricted_ssh" {
  name = "${var.name_prefix}-restricted-ssh"

  source {
    owner             = "AWS"
    source_identifier = "INCOMING_SSH_DISABLED"
  }
}

resource "aws_config_config_rule" "restricted_common_ports" {
  name = "${var.name_prefix}-restricted-common-ports"

  input_parameters = jsonencode({
    blockedPort1 = "20"
    blockedPort2 = "21"
    blockedPort3 = "3389"
    blockedPort4 = "3306"
    blockedPort5 = "1433"
  })

  source {
    owner             = "AWS"
    source_identifier = "RESTRICTED_INCOMING_TRAFFIC"
  }
}
