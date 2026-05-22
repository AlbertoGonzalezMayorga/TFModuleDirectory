# Azure Container Registry Terraform Module

Modulo para crear uno o varios Azure Container Registries.

## Ejemplo

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
