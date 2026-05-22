# Azure App Service Terraform Module

Modulo para crear App Service Plans y Linux Web Apps. Es una base Azure para aplicaciones web gestionadas, similar en proposito a Elastic Beanstalk.

## Que Crea

- `azurerm_service_plan`
- `azurerm_linux_web_app`

## Ejemplo

```hcl
module "app_service" {
  source = "./modules/Azure/Compute/app_service"

  service_plans = {
    platform-dev-plan = {
      resource_group_name = "rg-platform-dev"
      location            = "westeurope"
      sku_name            = "B1"
    }
  }

  linux_web_apps = {
    platform-dev-api = {
      resource_group_name = "rg-platform-dev"
      location            = "westeurope"
      service_plan_key    = "platform-dev-plan"

      app_settings = {
        WEBSITES_PORT = "8080"
      }

      docker_image_name   = "platform/api:latest"
      docker_registry_url = "https://platformdevacr.azurecr.io"
    }
  }
}
```

## Inputs Principales

- `service_plans`: planes a crear.
- `linux_web_apps`: apps Linux a crear.
- `service_plan_key`: key del plan dentro de `service_plans`.
- `app_settings`: variables de aplicacion.
- `docker_image_name`, `docker_registry_url`: stack container opcional.
- `identity_type`: `SystemAssigned` por defecto.

## Outputs

- `service_plans`: `id`, `name`.
- `linux_web_apps`: `id`, `name`, `default_hostname`.
