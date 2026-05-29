locals {
  vpc_id         = var.create_vpc ? aws_vpc.this[0].id : var.vpc_id
  vpc_cidr_block = var.create_vpc ? aws_vpc.this[0].cidr_block : var.vpc_cidr

  availability_zones = length(var.availability_zones) > 0 ? var.availability_zones : slice(data.aws_availability_zones.available[0].names, 0, var.az_count)

  public_subnet_count   = length(var.public_subnet_cidrs) > 0 ? length(var.public_subnet_cidrs) : var.public_subnet_count
  private_subnet_count  = length(var.private_subnet_cidrs) > 0 ? length(var.private_subnet_cidrs) : var.private_subnet_count
  isolated_subnet_count = length(var.isolated_subnet_cidrs) > 0 ? length(var.isolated_subnet_cidrs) : var.isolated_subnet_count

  public_subnet_cidrs = length(var.public_subnet_cidrs) > 0 ? var.public_subnet_cidrs : [
    for index in range(local.public_subnet_count) :
    cidrsubnet(var.vpc_cidr, var.subnet_newbits, index)
  ]

  private_subnet_cidrs = length(var.private_subnet_cidrs) > 0 ? var.private_subnet_cidrs : [
    for index in range(local.private_subnet_count) :
    cidrsubnet(var.vpc_cidr, var.subnet_newbits, local.public_subnet_count + index)
  ]

  isolated_subnet_cidrs = length(var.isolated_subnet_cidrs) > 0 ? var.isolated_subnet_cidrs : [
    for index in range(local.isolated_subnet_count) :
    cidrsubnet(var.vpc_cidr, var.subnet_newbits, local.public_subnet_count + local.private_subnet_count + index)
  ]

  nat_gateway_count = var.enable_nat_gateway && local.private_subnet_count > 0 && local.public_subnet_count > 0 ? (
    var.single_nat_gateway ? 1 : min(local.private_subnet_count, local.public_subnet_count)
  ) : 0

}
