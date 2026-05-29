# Azure Key Vault Secrets Terraform Module

Modulo para crear un Azure Key Vault y gestionar multiples secretos, o para usar un Key Vault existente y anadir secretos desde Terraform.

## Que Crea

- `azurerm_key_vault`, opcional
- `data.azurerm_key_vault`, opcional
- `azurerm_key_vault_access_policy`, opcional
- `azurerm_key_vault_secret`

## Crear Key Vault Con Secretos

```hcl
module "key_vault_secrets" {
  source = "./modules/Azure/Secrets/key_vault_secrets"

  name                = "kv-platform-dev"
  resource_group_name = "rg-platform-dev"
  location            = "westeurope"

  secrets = {
    database_password = {
      value        = var.database_password
      content_type = "password"
    }
  }

  tags = {
    environment = "dev"
  }
}
```

## Usar Key Vault Existente

```hcl
module "shared_key_vault_secrets" {
  source = "./modules/Azure/Secrets/key_vault_secrets"

  create_key_vault = false

  existing_key_vault = {
    name                = "kv-platform-shared"
    resource_group_name = "rg-shared"
  }

  secrets = {
    api_key = {
      value = var.api_key
    }
  }
}
```

## Multiples Key Vaults Desde Root

```hcl
module "key_vaults" {
  for_each = var.key_vaults

  source = "./modules/Azure/Secrets/key_vault_secrets"

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  secrets             = each.value.secrets
  tags                = each.value.tags
}
```

## Inputs Principales

- `create_key_vault`: crea un Key Vault nuevo cuando es `true`.
- `existing_key_vault`: Key Vault existente a consultar cuando `create_key_vault = false`.
- `name`, `resource_group_name`, `location`: obligatorios al crear Key Vault.
- `enable_rbac_authorization`: si es `true`, no se crean access policies.
- `access_policies`: politicas explicitas cuando se usa access policy mode.
- `enable_current_client_secret_permissions`: concede permisos de secretos al cliente que ejecuta Terraform.
- `secrets`: secretos a crear en el Key Vault efectivo.
- `tags`: etiquetas comunes.

## Outputs

- `key_vault`: metadatos del Key Vault efectivo.
- `key_vault_id`: ID del Key Vault efectivo.
- `key_vault_uri`: URI del Key Vault efectivo.
- `secrets`: IDs, nombres y versiones de secretos, sin exponer valores.

## Notas

Los valores de secretos quedan almacenados en el state de Terraform, como ocurre con cualquier recurso `azurerm_key_vault_secret`. Usa un backend remoto cifrado y acceso restringido.
