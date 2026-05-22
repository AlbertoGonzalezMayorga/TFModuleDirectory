# Azure AKS Terraform Module

Modulo para crear clusters AKS con node pool por defecto y node pools adicionales.

## Que Crea

- `azurerm_kubernetes_cluster`
- `azurerm_kubernetes_cluster_node_pool`, opcional

## Ejemplo Minimo

```hcl
module "aks" {
  source = "./modules/Azure/Containers/aks"

  clusters = {
    platform-dev = {
      resource_group_name = "rg-platform-dev"
      location            = "westeurope"
      dns_prefix          = "platform-dev"
    }
  }
}
```

## Ejemplo Con VNet Y Node Pools

```hcl
clusters = {
  platform-prod = {
    resource_group_name = "rg-platform-prod"
    location            = "westeurope"
    dns_prefix          = "platform-prod"
    sku_tier            = "Standard"

    default_node_pool = {
      name                 = "system"
      vm_size              = "Standard_D4s_v5"
      auto_scaling_enabled = true
      min_count            = 2
      max_count            = 5
      vnet_subnet_id       = module.vnet.subnets["platform-aks"].id
    }

    node_pools = {
      apps = {
        vm_size    = "Standard_D4s_v5"
        min_count  = 2
        max_count  = 10
        node_labels = {
          workload = "apps"
        }
      }
    }
  }
}
```

## Inputs Principales

- `clusters`: mapa de clusters AKS.
- `default_node_pool`: node pool de sistema.
- `node_pools`: node pools adicionales.
- `network_profile`: plugin, policy, service CIDR y outbound type.
- `private_cluster_enabled`.
- `role_based_access_control_enabled`.

## Outputs

- `clusters`: `id`, `name`, `kubelet_identity`, `node_resource_group`.
