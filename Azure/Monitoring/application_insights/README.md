# Azure Application Insights Terraform Module

Modulo para crear un componente de Application Insights, opcionalmente asociado a un Log Analytics Workspace.

## Que Crea

- `azurerm_application_insights`

## Ejemplo Minimo

```hcl
module "application_insights" {
  source = "./modules/Azure/Monitoring/application_insights"

  name                = "appi-api-dev"
  resource_group_name = "rg-platform-dev"
  location            = "westeurope"
}
```

## Ejemplo Workspace-Based

```hcl
module "application_insights" {
  source = "./modules/Azure/Monitoring/application_insights"

  name                = "appi-api-dev"
  resource_group_name = "rg-platform-dev"
  location            = "westeurope"
  application_type    = "web"
  workspace_id        = module.log_analytics_workspace.id
}
```

## Multiples Instancias Desde Root

```hcl
module "application_insights" {
  for_each = var.application_insights

  source = "./modules/Azure/Monitoring/application_insights"

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  workspace_id        = each.value.workspace_id
  tags                = each.value.tags
}
```

## Inputs Principales

- `name`: nombre del componente.
- `resource_group_name`: resource group.
- `location`: region Azure.
- `application_type`: tipo de aplicacion, `web` por defecto.
- `workspace_id`: Log Analytics Workspace para modo workspace-based.
- `retention_in_days`.
- `daily_data_cap_in_gb`.
- `sampling_percentage`.
- `internet_ingestion_enabled` e `internet_query_enabled`.
- `tags`.

## Outputs

- `id`
- `name`
- `app_id`
- `instrumentation_key`, sensitive
- `connection_string`, sensitive
- `workspace_id`
