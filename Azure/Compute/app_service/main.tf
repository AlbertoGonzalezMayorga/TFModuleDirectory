resource "azurerm_service_plan" "this" {
  for_each = var.service_plans

  name                = each.key
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  os_type             = each.value.os_type
  sku_name            = each.value.sku_name
  tags                = merge(var.tags, each.value.tags)
}

resource "azurerm_linux_web_app" "this" {
  for_each = var.linux_web_apps

  name                = each.key
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  service_plan_id     = azurerm_service_plan.this[each.value.service_plan_key].id
  https_only          = each.value.https_only
  app_settings        = each.value.app_settings
  tags                = merge(var.tags, each.value.tags)

  site_config {
    always_on = each.value.always_on

    dynamic "application_stack" {
      for_each = each.value.docker_image_name == null ? [] : [1]

      content {
        docker_image_name   = each.value.docker_image_name
        docker_registry_url = each.value.docker_registry_url
      }
    }
  }

  identity {
    type = each.value.identity_type
  }
}
