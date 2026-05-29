output "role_assignments" {
  description = "Azure RBAC role assignments keyed by logical name."
  value = {
    for key, assignment in azurerm_role_assignment.this : key => {
      id                   = assignment.id
      name                 = assignment.name
      scope                = assignment.scope
      principal_id         = assignment.principal_id
      principal_type       = assignment.principal_type
      role_definition_id   = assignment.role_definition_id
      role_definition_name = assignment.role_definition_name
    }
  }
}

output "role_assignment_ids" {
  description = "Azure RBAC role assignment IDs keyed by logical name."
  value = {
    for key, assignment in azurerm_role_assignment.this : key => assignment.id
  }
}
