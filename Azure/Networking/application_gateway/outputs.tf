output "application_gateways" {
  description = "Application Gateways keyed by name."
  value = {
    for name, gateway in azurerm_application_gateway.this : name => {
      id   = gateway.id
      name = gateway.name
    }
  }
}
