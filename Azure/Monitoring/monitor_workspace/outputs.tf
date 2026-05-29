output "id" {
  description = "Azure Monitor Workspace resource ID."
  value       = azurerm_monitor_workspace.this.id
}

output "name" {
  description = "Azure Monitor Workspace name."
  value       = azurerm_monitor_workspace.this.name
}

output "query_endpoint" {
  description = "Azure Monitor Workspace query endpoint."
  value       = azurerm_monitor_workspace.this.query_endpoint
}

output "default_data_collection_endpoint_id" {
  description = "Managed default Data Collection Endpoint ID."
  value       = azurerm_monitor_workspace.this.default_data_collection_endpoint_id
}

output "default_data_collection_rule_id" {
  description = "Managed default Data Collection Rule ID."
  value       = azurerm_monitor_workspace.this.default_data_collection_rule_id
}
