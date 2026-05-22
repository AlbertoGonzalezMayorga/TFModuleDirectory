output "virtual_networks" {
  description = "Virtual networks keyed by name."
  value = {
    for name, vnet in azurerm_virtual_network.this : name => {
      id            = vnet.id
      address_space = vnet.address_space
      name          = vnet.name
    }
  }
}

output "subnets" {
  description = "Subnets keyed by virtual-network-subnet name."
  value = {
    for name, subnet in azurerm_subnet.this : name => {
      id               = subnet.id
      name             = subnet.name
      address_prefixes = subnet.address_prefixes
    }
  }
}
