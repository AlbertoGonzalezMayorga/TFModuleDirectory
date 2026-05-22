output "nat_gateways" {
  description = "NAT gateways keyed by name."
  value = {
    for name, nat in azurerm_nat_gateway.this : name => {
      id   = nat.id
      name = nat.name
    }
  }
}
