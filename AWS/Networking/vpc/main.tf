data "aws_availability_zones" "available" {
  count = length(var.availability_zones) == 0 ? 1 : 0

  exclude_names = var.exclude_availability_zone_names
  state         = "available"
}

resource "aws_vpc" "this" {
  count = var.create_vpc ? 1 : 0

  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(
    var.tags,
    var.vpc_tags,
    {
      Name = var.name
    }
  )
}

resource "aws_internet_gateway" "this" {
  count = var.create_internet_gateway && local.public_subnet_count > 0 ? 1 : 0

  vpc_id = local.vpc_id

  tags = merge(
    var.tags,
    var.internet_gateway_tags,
    {
      Name = "${var.name}-igw"
    }
  )
}

resource "aws_subnet" "public" {
  count = local.public_subnet_count

  availability_zone       = local.availability_zones[count.index % length(local.availability_zones)]
  cidr_block              = local.public_subnet_cidrs[count.index]
  map_public_ip_on_launch = var.public_subnets_map_public_ip_on_launch
  vpc_id                  = local.vpc_id

  tags = merge(
    var.tags,
    var.public_subnet_tags,
    {
      Name = "${var.name}-public-${count.index + 1}"
      Tier = "public"
    }
  )
}

resource "aws_subnet" "private" {
  count = local.private_subnet_count

  availability_zone       = local.availability_zones[count.index % length(local.availability_zones)]
  cidr_block              = local.private_subnet_cidrs[count.index]
  map_public_ip_on_launch = false
  vpc_id                  = local.vpc_id

  tags = merge(
    var.tags,
    var.private_subnet_tags,
    {
      Name = "${var.name}-private-${count.index + 1}"
      Tier = "private"
    }
  )
}

resource "aws_subnet" "isolated" {
  count = local.isolated_subnet_count

  availability_zone       = local.availability_zones[count.index % length(local.availability_zones)]
  cidr_block              = local.isolated_subnet_cidrs[count.index]
  map_public_ip_on_launch = false
  vpc_id                  = local.vpc_id

  tags = merge(
    var.tags,
    var.isolated_subnet_tags,
    {
      Name = "${var.name}-isolated-${count.index + 1}"
      Tier = "isolated"
    }
  )
}

resource "aws_route_table" "public" {
  count = local.public_subnet_count > 0 ? 1 : 0

  vpc_id = local.vpc_id

  tags = merge(
    var.tags,
    var.public_route_table_tags,
    {
      Name = "${var.name}-public"
    }
  )
}

resource "aws_route" "public_internet_gateway" {
  count = var.create_internet_gateway && local.public_subnet_count > 0 ? 1 : 0

  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
  route_table_id         = aws_route_table.public[0].id
}

resource "aws_route_table_association" "public" {
  count = local.public_subnet_count

  route_table_id = aws_route_table.public[0].id
  subnet_id      = aws_subnet.public[count.index].id
}

resource "aws_eip" "nat" {
  count = local.nat_gateway_count

  domain = "vpc"

  tags = merge(
    var.tags,
    var.nat_gateway_tags,
    {
      Name = "${var.name}-nat-eip-${count.index + 1}"
    }
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  count = local.nat_gateway_count

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index % local.public_subnet_count].id

  tags = merge(
    var.tags,
    var.nat_gateway_tags,
    {
      Name = "${var.name}-nat-${count.index + 1}"
    }
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "private" {
  count = local.private_subnet_count

  vpc_id = local.vpc_id

  tags = merge(
    var.tags,
    var.private_route_table_tags,
    {
      Name = "${var.name}-private-${count.index + 1}"
    }
  )
}

resource "aws_route" "private_nat_gateway" {
  count = local.nat_gateway_count > 0 ? local.private_subnet_count : 0

  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[var.single_nat_gateway ? 0 : count.index % local.nat_gateway_count].id
  route_table_id         = aws_route_table.private[count.index].id
}

resource "aws_route_table_association" "private" {
  count = local.private_subnet_count

  route_table_id = aws_route_table.private[count.index].id
  subnet_id      = aws_subnet.private[count.index].id
}

resource "aws_route_table" "isolated" {
  count = local.isolated_subnet_count

  vpc_id = local.vpc_id

  tags = merge(
    var.tags,
    var.isolated_route_table_tags,
    {
      Name = "${var.name}-isolated-${count.index + 1}"
    }
  )
}

resource "aws_route_table_association" "isolated" {
  count = local.isolated_subnet_count

  route_table_id = aws_route_table.isolated[count.index].id
  subnet_id      = aws_subnet.isolated[count.index].id
}

resource "aws_cloudwatch_log_group" "this" {
  count = var.create_flow_log && var.log_destination_type == "cloud-watch-logs" ? 1 : 0

  name              = var.flow_log_cloudwatch_log_group_name == null ? "/aws/vpc/flow-logs/${local.vpc_id}" : var.flow_log_cloudwatch_log_group_name
  retention_in_days = var.flow_log_cloudwatch_log_group_retention_in_days

  tags = var.tags
}

resource "aws_flow_log" "this" {
  count = var.create_flow_log ? 1 : 0

  iam_role_arn         = var.log_destination_type == "cloud-watch-logs" ? var.flow_log_cloudwatch_iam_role_arn : null
  log_destination      = var.log_destination_type == "cloud-watch-logs" ? aws_cloudwatch_log_group.this[0].arn : var.logs_bucket_arn
  log_destination_type = var.log_destination_type
  traffic_type         = var.traffic_type
  vpc_id               = local.vpc_id

  tags = var.tags
}
