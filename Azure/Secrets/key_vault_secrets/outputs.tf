output "key_vault" {
  description = "Effective Key Vault metadata."
  value       = local.key_vault
}

output "key_vault_id" {
  description = "Effective Key Vault ID."
  value       = local.key_vault.id
}

output "key_vault_uri" {
  description = "Effective Key Vault URI."
  value       = local.key_vault.vault_uri
}

output "secrets" {
  description = "Key Vault secrets keyed by logical name. Secret values are not exposed."
  value = {
    for key, secret in azurerm_key_vault_secret.this : key => {
      id           = secret.id
      name         = secret.name
      key_vault_id = secret.key_vault_id
      version      = secret.version
    }
  }
}
