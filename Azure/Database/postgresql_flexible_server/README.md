# Azure PostgreSQL Flexible Server Terraform Module

Modulo para crear PostgreSQL Flexible Servers y bases de datos.

## Que Crea

- `azurerm_postgresql_flexible_server`
- `azurerm_postgresql_flexible_server_database`, opcional

## Ejemplo

```hcl
module "postgres" {
  source = "./modules/Azure/Database/postgresql_flexible_server"

  servers = {
    platform-dev-pg = {
      resource_group_name           = "rg-platform-dev"
      location                      = "westeurope"
      administrator_login           = "appadmin"
      administrator_password        = var.postgres_admin_password
      public_network_access_enabled = false
      delegated_subnet_id           = module.vnet.subnets["platform-db"].id
      private_dns_zone_id           = azurerm_private_dns_zone.postgres.id

      databases = {
        app = {}
      }
    }
  }
}
```

## Inputs Principales

- `servers`: mapa de servidores. La key es el nombre real.
- `version`, `sku_name`, `storage_mb`.
- `administrator_login`, `administrator_password`.
- `public_network_access_enabled`.
- `delegated_subnet_id`, `private_dns_zone_id` para despliegues privados.
- `databases`: bases de datos por servidor.

## Outputs

- `servers`: `id`, `name`, `fqdn`.

## Notas

Evita hardcodear `administrator_password`; pasalo desde una variable sensitive del root module o desde un gestor de secretos.
