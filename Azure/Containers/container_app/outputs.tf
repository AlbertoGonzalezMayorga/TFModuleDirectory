output "id" {
  description = "Container App resource ID."
  value       = azurerm_container_app.this.id
}

output "name" {
  description = "Container App name."
  value       = azurerm_container_app.this.name
}

output "latest_revision_name" {
  description = "Latest revision name."
  value       = azurerm_container_app.this.latest_revision_name
}

output "latest_revision_fqdn" {
  description = "Latest revision FQDN."
  value       = azurerm_container_app.this.latest_revision_fqdn
}

output "outbound_ip_addresses" {
  description = "Outbound IP addresses."
  value       = azurerm_container_app.this.outbound_ip_addresses
}

output "custom_domain_verification_id" {
  description = "Custom domain verification ID."
  value       = azurerm_container_app.this.custom_domain_verification_id
}

output "custom_domains" {
  description = "Custom domains keyed by logical name."
  value = {
    for key, domain in azurerm_container_app_custom_domain.this : key => {
      id   = domain.id
      name = domain.name
    }
  }
}
