output "registries" {
  description = "Azure Container Registries keyed by name."
  value = {
    for name, registry in azurerm_container_registry.this : name => {
      id           = registry.id
      login_server = registry.login_server
      name         = registry.name
      sku          = registry.sku
    }
  }
}
