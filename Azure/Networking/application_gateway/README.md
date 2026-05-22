# Azure Application Gateway Terraform Module

Modulo para crear Application Gateways HTTP basicos con backend FQDNs. Es la equivalencia Azure mas cercana a un ALB L7.

## Que Crea

- `azurerm_public_ip`, opcional
- `azurerm_application_gateway`

## Ejemplo

```hcl
module "application_gateway" {
  source = "./modules/Azure/Networking/application_gateway"

  application_gateways = {
    platform = {
      resource_group_name = "rg-platform-dev"
      location            = "westeurope"
      subnet_id           = module.vnet.subnets["platform-appgw"].id

      backend_fqdns = ["app.internal.example.com"]
    }
  }
}
```

## Inputs Principales

- `application_gateways`: mapa de gateways.
- `subnet_id`: subnet dedicada al Application Gateway.
- `sku_name`, `sku_tier`, `capacity`.
- `create_public_ip`: crea Public IP si es `true`.
- `backend_fqdns`, `backend_port`, `backend_protocol`.

## Outputs

- `application_gateways`: `id`, `name`.

## Notas

Este modulo cubre un caso HTTP basico. Para listeners HTTPS, path-based routing o WAF, extiende el modulo con bloques adicionales.
