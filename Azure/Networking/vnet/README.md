# Azure VNet Terraform Module

Modulo para crear VNets y subnets.

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
        apps = {
          address_prefixes = ["10.0.1.0/24"]
        }
      }
    }
  }
}
```
