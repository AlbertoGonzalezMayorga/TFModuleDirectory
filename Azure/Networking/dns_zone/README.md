# Azure DNS Zone Terraform Module

Modulo para crear Azure DNS Zones publicas o Private DNS Zones.

## Que Crea

- `azurerm_dns_zone`, para zonas publicas
- `azurerm_private_dns_zone`, para zonas privadas

## Ejemplo

```hcl
module "dns" {
  source = "./modules/Azure/Networking/dns_zone"

  zones = {
    public = {
      name                = "example.com"
      resource_group_name = "rg-platform-dns"
    }

    private = {
      name                = "internal.example.com"
      resource_group_name = "rg-platform-dns"
      private             = true
    }
  }
}
```

## Inputs Principales

- `zones`: mapa de zonas.
- `private`: crea Private DNS Zone si es `true`.
- `resource_group_name`.
- `tags`.

## Outputs

- `public_zones`: incluye name servers.
- `private_zones`.
