locals {
  containers = length(var.storage_accounts) == 0 ? {} : merge([
    for account_name, account in var.storage_accounts : {
      for container_name, container in account.containers :
      "${account_name}-${container_name}" => {
        name                  = container_name
        storage_account_key   = account_name
        container_access_type = container.container_access_type
      }
    }
  ]...)
}
