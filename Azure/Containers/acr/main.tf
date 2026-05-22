resource "azurerm_container_registry" "this" {
  for_each = var.registries

  name                          = each.key
  resource_group_name           = each.value.resource_group_name
  location                      = each.value.location
  sku                           = each.value.sku
  admin_enabled                 = each.value.admin_enabled
  public_network_access_enabled = each.value.public_network_access_enabled
  zone_redundancy_enabled       = each.value.zone_redundancy_enabled

  dynamic "georeplications" {
    for_each = each.value.georeplications

    content {
      location                = georeplications.value.location
      zone_redundancy_enabled = georeplications.value.zone_redundancy_enabled
      tags                    = merge(var.tags, georeplications.value.tags)
    }
  }

  tags = merge(var.tags, each.value.tags)
}
