data "azurerm_client_config" "current" {}

data "azurerm_key_vault" "existing" {
  count = var.create_key_vault ? 0 : 1

  name                = var.existing_key_vault == null ? null : var.existing_key_vault.name
  resource_group_name = var.existing_key_vault == null ? null : var.existing_key_vault.resource_group_name
}

resource "azurerm_key_vault" "this" {
  count = var.create_key_vault ? 1 : 0

  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  tenant_id                     = local.tenant_id
  sku_name                      = var.sku_name
  purge_protection_enabled      = var.purge_protection_enabled
  soft_delete_retention_days    = var.soft_delete_retention_days
  public_network_access_enabled = var.public_network_access_enabled
  enabled_for_disk_encryption   = var.enabled_for_disk_encryption
  rbac_authorization_enabled    = var.enable_rbac_authorization

  tags = var.tags
}

resource "azurerm_key_vault_access_policy" "this" {
  for_each = var.enable_rbac_authorization ? {} : local.access_policies

  key_vault_id   = local.key_vault_id
  tenant_id      = each.value.tenant_id
  object_id      = each.value.object_id
  application_id = each.value.application_id

  key_permissions         = each.value.key_permissions
  secret_permissions      = each.value.secret_permissions
  certificate_permissions = each.value.certificate_permissions
  storage_permissions     = each.value.storage_permissions
}

resource "azurerm_key_vault_secret" "this" {
  for_each = local.secrets

  name         = each.value.name
  value        = each.value.value
  key_vault_id = local.key_vault_id
  content_type = each.value.content_type

  tags = each.value.tags

  depends_on = [
    azurerm_key_vault_access_policy.this,
  ]
}
