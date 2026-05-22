# Azure Container Registry Terraform Module

Modulo para crear uno o varios Azure Container Registries.

## Que Crea

- `azurerm_container_registry`
- georeplicaciones opcionales en SKUs compatibles

## Ejemplo Minimo

```hcl
module "acr" {
  source = "./modules/Azure/Containers/acr"

  registries = {
    platformdevacr = {
      resource_group_name = "rg-platform-dev"
      location            = "westeurope"
      sku                 = "Standard"
    }
  }
}
```

## Ejemplo Premium Con Georeplicacion

```hcl
registries = {
  platformprodacr = {
    resource_group_name = "rg-platform-prod"
    location            = "westeurope"
    sku                 = "Premium"
    georeplications = [
      {
        location = "northeurope"
      }
    ]
  }
}
```

## Inputs Principales

- `registries`: mapa de ACRs. La key es el nombre del registry.
- `sku`: `Basic`, `Standard` o `Premium`.
- `admin_enabled`: activa usuario admin local.
- `public_network_access_enabled`.
- `zone_redundancy_enabled`.
- `georeplications`.

## Outputs

- `registries`: `id`, `name`, `sku`, `login_server`.
