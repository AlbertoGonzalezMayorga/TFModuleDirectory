# Azure NAT Gateway Terraform Module

Modulo para crear NAT Gateways, Public IPs asociadas y asociaciones opcionales con subnets.

## Que Crea

- `azurerm_public_ip`
- `azurerm_nat_gateway`
- `azurerm_nat_gateway_public_ip_association`
- `azurerm_subnet_nat_gateway_association`, opcional

## Ejemplo

```hcl
module "nat_gateway" {
  source = "./modules/Azure/Networking/nat_gateway"

  nat_gateways = {
    platform = {
      resource_group_name = "rg-platform-dev"
      location            = "westeurope"
      subnet_ids          = [module.vnet.subnets["platform-apps"].id]
    }
  }
}
```

## Inputs Principales

- `nat_gateways`: mapa de NAT Gateways.
- `idle_timeout_in_minutes`.
- `zones`.
- `subnet_ids`: subnets a asociar.

## Outputs

- `nat_gateways`: `id`, `name`.
