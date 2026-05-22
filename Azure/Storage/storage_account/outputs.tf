output "storage_accounts" {
  description = "Storage accounts keyed by name."
  value = {
    for name, account in azurerm_storage_account.this : name => {
      id                    = account.id
      name                  = account.name
      primary_blob_endpoint = account.primary_blob_endpoint
    }
  }
}

output "containers" {
  description = "Storage containers keyed by storage-account-container name."
  value = {
    for name, container in azurerm_storage_container.this : name => {
      id   = container.id
      name = container.name
    }
  }
}
