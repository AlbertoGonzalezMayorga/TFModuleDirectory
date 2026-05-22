resource "azurerm_public_ip" "this" {
  for_each = var.nat_gateways

  name                = "${each.key}-pip"
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = each.value.zones
  tags                = merge(var.tags, each.value.tags)
}

resource "azurerm_nat_gateway" "this" {
  for_each = var.nat_gateways

  name                    = each.key
  resource_group_name     = each.value.resource_group_name
  location                = each.value.location
  idle_timeout_in_minutes = each.value.idle_timeout_in_minutes
  sku_name                = "Standard"
  zones                   = each.value.zones
  tags                    = merge(var.tags, each.value.tags)
}

resource "azurerm_nat_gateway_public_ip_association" "this" {
  for_each = var.nat_gateways

  nat_gateway_id       = azurerm_nat_gateway.this[each.key].id
  public_ip_address_id = azurerm_public_ip.this[each.key].id
}

resource "azurerm_subnet_nat_gateway_association" "this" {
  for_each = local.subnet_associations

  nat_gateway_id = azurerm_nat_gateway.this[each.value.nat_gateway_key].id
  subnet_id      = each.value.subnet_id
}
