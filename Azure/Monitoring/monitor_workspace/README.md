# Azure Monitor Workspace Terraform Module

Modulo para crear un Azure Monitor Workspace, usado por escenarios como managed Prometheus y metricas de Azure Monitor.

## Que Crea

- `azurerm_monitor_workspace`

## Ejemplo Minimo

```hcl
module "monitor_workspace" {
  source = "./modules/Azure/Monitoring/monitor_workspace"

  name                = "amw-platform-dev"
  resource_group_name = "rg-platform-dev"
  location            = "westeurope"
}
```

## Ejemplo Con Red Publica Deshabilitada

```hcl
module "monitor_workspace" {
  source = "./modules/Azure/Monitoring/monitor_workspace"

  name                          = "amw-platform-prod"
  resource_group_name           = "rg-platform-prod"
  location                      = "westeurope"
  public_network_access_enabled = false
}
```

## Multiples Workspaces Desde Root

```hcl
module "monitor_workspaces" {
  for_each = var.monitor_workspaces

  source = "./modules/Azure/Monitoring/monitor_workspace"

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
- `public_network_access_enabled`: `true` por defecto.
- `tags`.

## Outputs

- `id`
- `name`
- `query_endpoint`
- `default_data_collection_endpoint_id`
- `default_data_collection_rule_id`
