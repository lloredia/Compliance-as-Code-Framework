# VPC Flow Logs Module - Enable network traffic logging
# Helps with security monitoring and network troubleshooting

# Data source to get all VPCs in the account
data "aws_vpcs" "all" {}

data "aws_vpc" "selected" {
  for_each = toset(data.aws_vpcs.all.ids)
  id       = each.value
}

# CloudWatch Log Group for Flow Logs
resource "aws_cloudwatch_log_group" "flow_logs" {
  for_each = var.enable_per_vpc ? toset(data.aws_vpcs.all.ids) : toset([])
  
  name              = "/aws/vpc/flowlogs/${each.value}"
  retention_in_days = var.log_retention_days

  tags = merge(
    var.tags,
    {
      Name = "VPC Flow Logs - ${each.value}"
    }
  )
}

# IAM role for VPC Flow Logs
resource "aws_iam_role" "flow_logs" {
  count = var.enable_per_vpc ? 1 : 0
  
  name = "${var.role_name_prefix}-vpc-flow-logs"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

# IAM policy for Flow Logs to write to CloudWatch
resource "aws_iam_role_policy" "flow_logs" {
  count = var.enable_per_vpc ? 1 : 0
  
  name = "vpc-flow-logs-policy"
  role = aws_iam_role.flow_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

# Enable Flow Logs for each VPC
resource "aws_flow_log" "main" {
  for_each = var.enable_per_vpc ? toset(data.aws_vpcs.all.ids) : toset([])

  vpc_id          = each.value
  traffic_type    = var.traffic_type
  iam_role_arn    = aws_iam_role.flow_logs[0].arn
  log_destination = aws_cloudwatch_log_group.flow_logs[each.value].arn

  tags = merge(
    var.tags,
    {
      Name   = "Flow Logs - ${each.value}"
      VPC_ID = each.value
    }
  )

  depends_on = [aws_iam_role_policy.flow_logs]
}
