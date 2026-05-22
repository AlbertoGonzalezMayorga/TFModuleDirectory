# Azure Front Door Terraform Module

Modulo para crear Azure Front Door Standard/Premium con profiles, endpoints, origin groups, origins y routes. Es la equivalencia Azure mas cercana a CloudFront.

## Que Crea

- `azurerm_cdn_frontdoor_profile`
- `azurerm_cdn_frontdoor_endpoint`
- `azurerm_cdn_frontdoor_origin_group`
- `azurerm_cdn_frontdoor_origin`
- `azurerm_cdn_frontdoor_route`

## Ejemplo

```hcl
module "front_door" {
  source = "./modules/Azure/Networking/front_door"

  profiles = {
    platform = {
      resource_group_name = "rg-platform-dev"

      endpoints = {
        public = {}
      }

      origin_groups = {
        apps = {
          origins = {
            app = {
              host_name          = "platform-dev-app.azurewebsites.net"
              origin_host_header = "platform-dev-app.azurewebsites.net"
            }
          }
        }
      }

      routes = {
        default = {
          endpoint_key     = "public"
          origin_group_key = "apps"
          origin_keys      = ["app"]
        }
      }
    }
  }
}
```

## Inputs Principales

- `profiles`: mapa de Front Door profiles.
- `endpoints`: endpoints por profile.
- `origin_groups`: grupos de origins y origins.
- `routes`: rutas que conectan endpoint, origin group y origins.
- `sku_name`: `Standard_AzureFrontDoor` o `Premium_AzureFrontDoor`.

## Outputs

- `profiles`: `id`, `name`.

## Notas

El modulo no configura custom domains, WAF policies ni rule sets todavia. Esta pensado como base generica ampliable.
