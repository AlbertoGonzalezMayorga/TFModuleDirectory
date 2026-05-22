resource "azurerm_dns_zone" "public" {
  for_each = { for key, zone in var.zones : key => zone if !zone.private }

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  tags                = merge(var.tags, each.value.tags)
}

resource "azurerm_private_dns_zone" "private" {
  for_each = { for key, zone in var.zones : key => zone if zone.private }

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  tags                = merge(var.tags, each.value.tags)
}
