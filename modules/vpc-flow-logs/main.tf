data "aws_vpcs" "all" {}

data "aws_region" "current" {}

locals {
  vpc_ids = var.enable_per_vpc ? toset(data.aws_vpcs.all.ids) : toset([])
}

module "kms" {
  source = "../cmk"

  name               = "${var.role_name_prefix}-vpc-flow-logs"
  description        = "Encrypts VPC flow log groups."
  service_principals = ["logs.${data.aws_region.current.name}.amazonaws.com"]
  tags               = var.tags
}

resource "aws_cloudwatch_log_group" "flow_logs" {
  for_each = local.vpc_ids

  name              = "/aws/vpc/flowlogs/${each.value}"
  retention_in_days = var.log_retention_days
  kms_key_id        = module.kms.key_arn

  tags = merge(var.tags, {
    Name = "VPC Flow Logs - ${each.value}"
  })
}

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "flow_logs" {
  count = length(local.vpc_ids) > 0 ? 1 : 0

  name               = "${var.role_name_prefix}-vpc-flow-logs"
  assume_role_policy = data.aws_iam_policy_document.assume.json

  tags = var.tags
}

data "aws_iam_policy_document" "flow_logs" {
  count = length(local.vpc_ids) > 0 ? 1 : 0

  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
    ]
    resources = concat(
      [for group in aws_cloudwatch_log_group.flow_logs : group.arn],
      [for group in aws_cloudwatch_log_group.flow_logs : "${group.arn}:*"],
    )
  }
}

resource "aws_iam_role_policy" "flow_logs" {
  count = length(local.vpc_ids) > 0 ? 1 : 0

  name   = "vpc-flow-logs"
  role   = aws_iam_role.flow_logs[0].id
  policy = data.aws_iam_policy_document.flow_logs[0].json
}

resource "aws_flow_log" "main" {
  for_each = local.vpc_ids

  vpc_id               = each.value
  traffic_type         = var.traffic_type
  iam_role_arn         = aws_iam_role.flow_logs[0].arn
  log_destination      = aws_cloudwatch_log_group.flow_logs[each.value].arn
  log_destination_type = "cloud-watch-logs"

  tags = merge(var.tags, {
    Name = "Flow Logs - ${each.value}"
  })

  depends_on = [aws_iam_role_policy.flow_logs]
}
