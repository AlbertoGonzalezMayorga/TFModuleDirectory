# Azure Log Analytics Workspace Terraform Module

Modulo para crear un Log Analytics Workspace reusable para logs, metricas y recursos como Application Insights.

## Que Crea

- `azurerm_log_analytics_workspace`

## Ejemplo Minimo

```hcl
module "log_analytics_workspace" {
  source = "./modules/Azure/Monitoring/log_analytics_workspace"

  name                = "log-platform-dev"
  resource_group_name = "rg-platform-dev"
  location            = "westeurope"
}
```

## Ejemplo Con Retencion Y Cuota

```hcl
module "log_analytics_workspace" {
  source = "./modules/Azure/Monitoring/log_analytics_workspace"

  name                = "log-platform-prod"
  resource_group_name = "rg-platform-prod"
  location            = "westeurope"
  retention_in_days   = 90
  daily_quota_gb      = 10

  tags = {
    environment = "prod"
  }
}
```

## Multiples Workspaces Desde Root

```hcl
module "log_analytics_workspaces" {
  for_each = var.log_analytics_workspaces

  source = "./modules/Azure/Monitoring/log_analytics_workspace"

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  tags                = each.value.tags
}
```

## Inputs Principales

- `name`: nombre del workspace.
- `resource_group_name`: resource group.
- `location`: region Azure.
- `sku`: `PerGB2018` por defecto.
- `retention_in_days`: `30` por defecto.
- `daily_quota_gb`: `-1` por defecto, sin cuota diaria.
- `internet_ingestion_enabled` e `internet_query_enabled`.
- `reservation_capacity_in_gb_per_day`.
- `allow_resource_only_permissions`.
- `local_authentication_disabled`.
- `tags`.

## Outputs

- `id`
- `name`
- `workspace_id`
- `primary_shared_key`, sensitive
- `secondary_shared_key`, sensitive
- `location`
