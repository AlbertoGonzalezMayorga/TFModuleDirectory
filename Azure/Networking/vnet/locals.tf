locals {
  subnets = merge([
    for vnet_name, vnet in var.virtual_networks : {
      for subnet_name, subnet in vnet.subnets :
      "${vnet_name}-${subnet_name}" => {
        name                 = subnet_name
        resource_group_name  = vnet.resource_group_name
        virtual_network_name = azurerm_virtual_network.this[vnet_name].name
        address_prefixes     = subnet.address_prefixes
        service_endpoints    = subnet.service_endpoints
      }
    }
  ]...)
}
