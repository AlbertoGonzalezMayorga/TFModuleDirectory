# Azure AKS Terraform Module

Modulo para crear clusters AKS con node pool por defecto y node pools adicionales.

## Ejemplo

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
