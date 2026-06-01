# Azure Container App Terraform Module

Modulo para crear una Azure Container App plug and play. Permite definir imagen, secretos, variables de entorno, registry, ingress, dominios custom e identidad administrada opcional.

## Que Crea
- `azurerm_container_app_environment`, opcional
- `azurerm_container_app`
- `azurerm_container_app_custom_domain`, opcional

## Ejemplo Minimo

Si no se define `image`, se usa `mcr.microsoft.com/azuredocs/containerapps-helloworld:latest`. Por defecto, el modulo crea un Container App Environment con el nombre indicado en `container_app_environment_name`.

```hcl
module "container_app" {
  source = "./modules/Azure/Containers/container_app"

  container_app_name             = "ca-api-dev"
  container_app_environment_name = "ca-api-dev-env"
  resource_group_name            = "rg-platform-dev"

  ingress = {
    external_enabled = true
    target_port      = 80
  }
}
```

## Gestion Del Container App Environment

El modulo puede crear el Container App Environment o enlazar la app a uno existente.

- `create_container_app_environment = true` es el valor por defecto. El modulo crea `azurerm_container_app_environment.this` usando `container_app_environment_name`, `resource_group_name`, `location` y `tags`.
- `create_container_app_environment = false` no crea el environment. El modulo lee un environment existente por `container_app_environment_name` y `resource_group_name`.
- `location` y `tags` solo afectan al environment cuando el modulo lo crea. La Container App siempre usa el environment efectivo, creado o existente.

Ejemplo usando un environment existente:

```hcl
module "container_app" {
  source = "./modules/Azure/Containers/container_app"

  create_container_app_environment = false
  container_app_environment_name   = "ca-shared-dev-env"
  container_app_name               = "ca-api-dev"
  resource_group_name              = "rg-platform-dev"
  image                            = "nginx:latest"

  ingress = {
    external_enabled = true
    target_port      = 80
  }
}
```

Cuando varias apps comparten el mismo environment, crea el environment una sola vez y configura el resto de apps con `create_container_app_environment = false`.

## Ejemplo Con Imagen, Secrets Y Env Vars

```hcl
module "container_app" {
  source = "./modules/Azure/Containers/container_app"

  container_app_name              = "ca-api-dev"
  container_app_environment_name  = "ca-api-dev-env"
  resource_group_name             = "rg-platform-dev"
  image                           = "nginx:latest"

  ingress = {
    external_enabled = true
    target_port      = 80
  }

  secrets = {
    database-password = {
      value = var.database_password
    }
  }

  env = {
    ASPNETCORE_ENVIRONMENT = {
      value = "Development"
    }

    DATABASE_PASSWORD = {
      secret_name = "database-password"
    }
  }
}
```

## Ejemplo Con Secret De Key Vault

Los secretos tambien pueden apuntar a Azure Key Vault. En ese caso, el secreto define `key_vault_secret_id` y la `identity` que Container Apps usara para leerlo. La identidad debe existir en la Container App mediante el bloque `identity` y debe tener permisos sobre el Key Vault mediante RBAC o access policy.

```hcl
module "container_app" {
  source = "./modules/Azure/Containers/container_app"

  container_app_name             = "ca-api-dev"
  container_app_environment_name = "ca-api-dev-env"
  resource_group_name            = "rg-platform-dev"
  image                          = "nginx:latest"

  identity = {
    type = "SystemAssigned"
  }

  secrets = {
    database-password = {
      key_vault_secret_id = azurerm_key_vault_secret.database_password.id
      identity            = "System"
    }
  }

  env = {
    DATABASE_PASSWORD = {
      secret_name = "database-password"
    }
  }
}
```

Para identidad user-assigned, incluye el resource ID en `identity.identity_ids` y usa ese mismo resource ID en `secrets[*].identity`.

## Ejemplo Con ACR

```hcl
module "container_app" {
  source = "./modules/Azure/Containers/container_app"

  container_app_name             = "ca-api-dev"
  container_app_environment_name = "ca-api-dev-env"
  resource_group_name            = "rg-platform-dev"
  image                          = "myacr.azurecr.io/api:latest"

  secrets = {
    acr-password = {
      value = var.acr_password
    }
  }

  registries = {
    acr = {
      server               = "myacr.azurecr.io"
      username             = "myacr"
      password_secret_name = "acr-password"
    }
  }
}
```

## Ejemplo Con Dominio Custom

```hcl
module "container_app" {
  source = "./modules/Azure/Containers/container_app"

  container_app_name             = "ca-api-prod"
  container_app_environment_name = "ca-api-prod-env"
  resource_group_name            = "rg-platform-prod"

  ingress = {
    external_enabled = true
    target_port      = 8080
  }

  custom_domains = {
    api = {
      container_app_name                       = "api.example.com"
      certificate_binding_type                 = "SniEnabled"
      container_app_environment_certificate_id = module.container_app_certificate.id
    }
  }
}
```

## Multiples Apps Desde Root

```hcl
module "container_apps" {
  for_each = var.container_apps

  source = "./modules/Azure/Containers/container_app"

  container_app_name             = each.value.container_app_name
  container_app_environment_name = each.value.container_app_environment_name
  resource_group_name            = each.value.resource_group_name 
  image                          = each.value.image
  ingress                        = each.value.ingress
  env                            = each.value.env
  secrets                        = each.value.secrets
  tags                           = each.value.tags
}
```

## Inputs Principales

- `container_app_name`: nombre de la Container App.
- `container_app_environment_name`: nombre del Container App Environment que se crea o se busca.
- `create_container_app_environment`: si es `true`, crea un Container App Environment. Si es `false`, usa uno existente por nombre y resource group.
- `resource_group_name`: resource group.
- `image`: imagen del contenedor. Usa hello-world de Azure por defecto.
- `container_name`, `cpu`, `memory`, `command`, `args`.
- `env`: variables de entorno con `value` o `secret_name`.
- `secrets`: secretos de Container Apps. Cada secreto puede usar `value` para un valor nativo o `key_vault_secret_id` + `identity` para referenciar Key Vault.
- `registries`: registries privados con password secret o managed identity.
- `ingress`: exposicion HTTP/TCP.
- `custom_domains`: dominios custom.
- `identity`: identidad administrada opcional para la Container App. Puede usarse para Key Vault secrets y ACR.
- `min_replicas`, `max_replicas`.
- `tags`.

## Outputs

- `id`
- `name`
- `latest_revision_name`
- `latest_revision_fqdn`
- `outbound_ip_addresses`
- `custom_domain_verification_id`
- `custom_domains`

## Notas

Los secretos definidos con `value` quedan almacenados en el state de Terraform. Usa un backend remoto cifrado y acceso restringido.

Los secretos definidos con `key_vault_secret_id` referencian Key Vault y evitan guardar el valor del secreto en el state de este modulo. Aun asi, debes conceder a la identidad de la Container App permiso para leer secretos en Key Vault antes de que la app pueda resolverlos.
