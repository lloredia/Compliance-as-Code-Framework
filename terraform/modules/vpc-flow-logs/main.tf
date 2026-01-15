# VPC Flow Logs Module - Enables flow logs for all VPCs
data "aws_vpcs" "all" {}

data "aws_vpc" "selected" {
  for_each = toset(data.aws_vpcs.all.ids)
  id       = each.value
}

# CloudWatch Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "flow_logs" {
  name              = "/aws/vpc/flowlogs"
  retention_in_days = var.retention_days

  tags = var.tags
}

# IAM role for VPC Flow Logs
resource "aws_iam_role" "flow_logs" {
  name = "vpc-flow-logs-role"

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

# IAM policy for VPC Flow Logs
resource "aws_iam_role_policy" "flow_logs" {
  name = "vpc-flow-logs-policy"
  role = aws_iam_role.flow_logs.id

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

# Enable flow logs for all VPCs
resource "aws_flow_log" "vpc_flow_logs" {
  for_each = data.aws_vpc.selected

  vpc_id          = each.value.id
  traffic_type    = var.traffic_type
  iam_role_arn    = aws_iam_role.flow_logs.arn
  log_destination = aws_cloudwatch_log_group.flow_logs.arn

  tags = merge(
    var.tags,
    {
      Name   = "flow-log-${each.value.id}"
      VPC_ID = each.value.id
    }
  )
}
