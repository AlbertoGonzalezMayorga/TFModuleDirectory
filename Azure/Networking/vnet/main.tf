resource "azurerm_virtual_network" "this" {
  for_each = var.virtual_networks

  name                = each.key
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  address_space       = each.value.address_space
  dns_servers         = each.value.dns_servers
  tags                = merge(var.tags, each.value.tags)
}

resource "azurerm_subnet" "this" {
  for_each = local.subnets

  name                 = each.value.name
  resource_group_name  = each.value.resource_group_name
  virtual_network_name = each.value.virtual_network_name
  address_prefixes     = each.value.address_prefixes
  service_endpoints    = each.value.service_endpoints
}
