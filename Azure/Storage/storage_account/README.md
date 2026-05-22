# Azure Storage Account Terraform Module

Modulo para crear Storage Accounts y containers.

## Ejemplo

```hcl
module "storage" {
  source = "./modules/Azure/Storage/storage_account"

  storage_accounts = {
    platformdevlogs = {
      resource_group_name = "rg-platform-dev"
      location            = "westeurope"
      containers = {
        logs = {}
      }
    }
  }
}
```
