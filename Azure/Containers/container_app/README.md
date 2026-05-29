# Azure Container App Terraform Module

Modulo para crear una Azure Container App plug and play. Permite definir imagen, secretos, variables de entorno, registry, ingress, dominios custom e identidad administrada opcional.

## Que Crea
- `azurerm_container_app_environment`, opcional
- `azurerm_container_app`
- `azurerm_container_app_custom_domain`, opcional

## Ejemplo Minimo

Si no se define `image`, se usa `mcr.microsoft.com/azuredocs/containerapps-helloworld:latest`.

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
      container_app_name                                     = "api.example.com"
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
- `container_app_environment_name`: Name del Container App Environment.
- `resource_group_name`: resource group.
- `image`: imagen del contenedor. Usa hello-world de Azure por defecto.
- `container_name`, `cpu`, `memory`, `command`, `args`.
- `env`: variables de entorno con `value` o `secret_name`.
- `secrets`: secretos nativos de Container Apps.
- `registries`: registries privados con password secret o managed identity.
- `ingress`: exposicion HTTP/TCP.
- `custom_domains`: dominios custom.
- `identity`: identidad administrada opcional.
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

Los valores de `secrets` quedan almacenados en el state de Terraform. Usa un backend remoto cifrado y acceso restringido.
