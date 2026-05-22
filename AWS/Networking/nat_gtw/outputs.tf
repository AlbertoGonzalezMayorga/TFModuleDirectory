output "nat_gateways" {
  description = "NAT gateways keyed by name."
  value = {
    for name, nat in aws_nat_gateway.this : name => {
      allocation_id = nat.allocation_id
      id            = nat.id
      public_ip     = aws_eip.this[name].public_ip
    }
  }
}
