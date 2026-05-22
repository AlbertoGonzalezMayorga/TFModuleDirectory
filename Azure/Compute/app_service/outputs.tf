output "service_plans" {
  description = "App Service plans keyed by name."
  value = {
    for name, plan in azurerm_service_plan.this : name => {
      id   = plan.id
      name = plan.name
    }
  }
}

output "linux_web_apps" {
  description = "Linux Web Apps keyed by name."
  value = {
    for name, app in azurerm_linux_web_app.this : name => {
      default_hostname = app.default_hostname
      id               = app.id
      name             = app.name
    }
  }
}
