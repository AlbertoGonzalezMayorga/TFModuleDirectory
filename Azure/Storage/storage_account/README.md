# Azure Storage Account Terraform Module

Modulo para crear Storage Accounts y containers con defaults seguros.

## Que Crea

- `azurerm_storage_account`
- `azurerm_storage_container`, opcional

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
        artifacts = {
          container_access_type = "private"
        }
      }
    }
  }
}
```

## Inputs Principales

- `storage_accounts`: mapa de cuentas. La key es el nombre real.
- `account_tier`, `account_replication_type`, `account_kind`.
- `allow_nested_items_to_be_public`: `false` por defecto.
- `min_tls_version`: `TLS1_2` por defecto.
- `blob_versioning_enabled`.
- `blob_delete_retention_days`.
- `containers`: containers por storage account.

## Outputs

- `storage_accounts`: `id`, `name`, `primary_blob_endpoint`.
- `containers`: containers creados.
