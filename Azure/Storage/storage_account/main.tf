resource "azurerm_storage_account" "this" {
  for_each = var.storage_accounts

  name                            = each.key
  resource_group_name             = each.value.resource_group_name
  location                        = each.value.location
  account_tier                    = each.value.account_tier
  account_replication_type        = each.value.account_replication_type
  account_kind                    = each.value.account_kind
  access_tier                     = each.value.access_tier
  allow_nested_items_to_be_public = each.value.allow_nested_items_to_be_public
  min_tls_version                 = each.value.min_tls_version
  public_network_access_enabled   = each.value.public_network_access_enabled
  shared_access_key_enabled       = each.value.shared_access_key_enabled
  tags                            = merge(var.tags, each.value.tags)

  blob_properties {
    versioning_enabled = each.value.blob_versioning_enabled

    delete_retention_policy {
      days = each.value.blob_delete_retention_days
    }

    container_delete_retention_policy {
      days = each.value.container_delete_retention_days
    }
  }
}

resource "azurerm_storage_container" "this" {
  for_each = local.containers

  name                  = each.value.name
  storage_account_id    = azurerm_storage_account.this[each.value.storage_account_key].id
  container_access_type = each.value.container_access_type
}
