# Azure AKS Add-ons

Modulo reutilizable para instalar extensiones sobre un cluster AKS mediante `azurerm_kubernetes_cluster_extension`. Es la contraparte Azure para gestionar capacidades adicionales del cluster desde Terraform cuando no forman parte directa de la definicion base del AKS.

## Uso

```hcl
module "aks_addons" {
  source = "./Azure/Containers/aks-addons"

  cluster_id = module.aks.clusters.platform.id

  extensions = {
    azure_monitor = {
      extension_type = "microsoft.azuremonitor.containers"
      release_train  = "Stable"

      configuration_settings = {
        "amalogs.useAADAuth" = "true"
      }
    }
  }
}
```

## Entradas principales

- `cluster_id`: ID del cluster AKS donde se instalan las extensiones.
- `extensions`: mapa de extensiones a crear.
- `configuration_settings`: configuracion no sensible de la extension.
- `configuration_protected_settings`: configuracion sensible de la extension.
- `plan`: bloque opcional para extensiones con marketplace plan.

## Salidas

- `extensions`: IDs y metadatos basicos de cada extension.
