output "id" {
  description = "Application Insights resource ID."
  value       = azurerm_application_insights.this.id
}

output "name" {
  description = "Application Insights name."
  value       = azurerm_application_insights.this.name
}

output "app_id" {
  description = "Application Insights app ID."
  value       = azurerm_application_insights.this.app_id
}

output "instrumentation_key" {
  description = "Application Insights instrumentation key."
  value       = azurerm_application_insights.this.instrumentation_key
  sensitive   = true
}

output "connection_string" {
  description = "Application Insights connection string."
  value       = azurerm_application_insights.this.connection_string
  sensitive   = true
}

output "workspace_id" {
  description = "Associated Log Analytics Workspace ID."
  value       = azurerm_application_insights.this.workspace_id
}
