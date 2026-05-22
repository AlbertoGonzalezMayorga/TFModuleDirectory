resource "aws_eip" "this" {
  for_each = var.nat_gateways

  domain = "vpc"
  tags   = merge(var.tags, each.value.tags)
}

resource "aws_nat_gateway" "this" {
  for_each = var.nat_gateways

  allocation_id     = aws_eip.this[each.key].id
  connectivity_type = "public"
  subnet_id         = each.value.subnet_id
  tags              = merge(var.tags, each.value.tags)
}

resource "aws_route" "this" {
  for_each = local.routes

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
  nat_gateway_id         = aws_nat_gateway.this[each.value.nat_gateway_key].id
}
