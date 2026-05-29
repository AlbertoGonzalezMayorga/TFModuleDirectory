locals {
  tenant_id = coalesce(var.tenant_id, data.azurerm_client_config.current.tenant_id)

  key_vault_id = var.create_key_vault ? azurerm_key_vault.this[0].id : data.azurerm_key_vault.existing[0].id
  key_vault = var.create_key_vault ? {
    id                  = azurerm_key_vault.this[0].id
    name                = azurerm_key_vault.this[0].name
    resource_group_name = azurerm_key_vault.this[0].resource_group_name
    location            = azurerm_key_vault.this[0].location
    vault_uri           = azurerm_key_vault.this[0].vault_uri
    tenant_id           = azurerm_key_vault.this[0].tenant_id
    } : {
    id                  = data.azurerm_key_vault.existing[0].id
    name                = data.azurerm_key_vault.existing[0].name
    resource_group_name = data.azurerm_key_vault.existing[0].resource_group_name
    location            = data.azurerm_key_vault.existing[0].location
    vault_uri           = data.azurerm_key_vault.existing[0].vault_uri
    tenant_id           = data.azurerm_key_vault.existing[0].tenant_id
  }

  current_client_access_policies = var.enable_current_client_secret_permissions ? {
    current-client = {
      tenant_id               = local.tenant_id
      object_id               = data.azurerm_client_config.current.object_id
      application_id          = null
      key_permissions         = []
      secret_permissions      = var.current_client_secret_permissions
      certificate_permissions = []
      storage_permissions     = []
    }
  } : {}

  access_policies = merge(local.current_client_access_policies, {
    for key, policy in var.access_policies : key => merge(policy, {
      tenant_id = coalesce(policy.tenant_id, local.tenant_id)
    })
  })

  secrets = {
    for key, secret in var.secrets : key => merge(secret, {
      name = coalesce(secret.name, key)
      tags = merge(var.tags, coalesce(secret.tags, {}))
    })
  }
}
