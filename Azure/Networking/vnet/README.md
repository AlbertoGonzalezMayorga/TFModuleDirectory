# Azure VNet Terraform Module

Modulo para crear una o varias Virtual Networks y sus subnets.

## Que Crea

- `azurerm_virtual_network`
- `azurerm_subnet`

## Ejemplo

```hcl
module "vnet" {
  source = "./modules/Azure/Networking/vnet"

  virtual_networks = {
    platform = {
      resource_group_name = "rg-platform-dev"
      location            = "westeurope"
      address_space       = ["10.0.0.0/16"]

      subnets = {
        aks = {
          address_prefixes = ["10.0.1.0/24"]
        }

        private_endpoints = {
          address_prefixes  = ["10.0.2.0/24"]
          service_endpoints = ["Microsoft.Storage"]
        }
      }
    }
  }
}
```

## Inputs Principales

- `virtual_networks`: mapa de VNets.
- `address_space`: CIDRs de la VNet.
- `dns_servers`: servidores DNS opcionales.
- `subnets`: mapa de subnets por VNet.
- `service_endpoints`: service endpoints por subnet.

## Outputs

- `virtual_networks`: VNets por nombre.
- `subnets`: subnets por `vnet-subnet`.
