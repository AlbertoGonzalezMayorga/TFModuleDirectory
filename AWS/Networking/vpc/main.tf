resource "aws_cloudwatch_log_group" "this" {
  count = var.create_flow_log && var.log_destination_type == "cloud-watch-logs" ? 1 : 0
  name  = "/aws/vpc/flow-logs/${aws_vpc.this[0].id}"
}

resource "aws_flow_log" "this" {
  count                = var.create_flow_log ? 1 : 0
  log_destination      = var.log_destination_type == "cloud-watch-logs" ? aws_cloudwatch_log_group.this[0].arn : var.logs_bucket_arn
  log_destination_type = var.log_destination_type
  traffic_type         = var.traffic_type
  vpc_id               = aws_vpc.this[0].id
}

resource "aws_vpc" "this" {
  count                = var.create_vpc ? 1 : 0
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = var.tags
}

