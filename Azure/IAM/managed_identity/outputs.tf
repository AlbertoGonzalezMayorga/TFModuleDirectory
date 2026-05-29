output "identities" {
  description = "Managed identities keyed by logical name."
  value = {
    for key, identity in azurerm_user_assigned_identity.this : key => {
      id                  = identity.id
      name                = identity.name
      resource_group_name = identity.resource_group_name
      location            = identity.location
      client_id           = identity.client_id
      principal_id        = identity.principal_id
      tenant_id           = identity.tenant_id
    }
  }
}

output "client_ids" {
  description = "Managed identity client IDs keyed by logical name."
  value = {
    for key, identity in azurerm_user_assigned_identity.this : key => identity.client_id
  }
}

output "principal_ids" {
  description = "Managed identity principal IDs keyed by logical name."
  value = {
    for key, identity in azurerm_user_assigned_identity.this : key => identity.principal_id
  }
}

output "role_assignments" {
  description = "Role assignment IDs keyed by identity-assignment name."
  value = {
    for key, assignment in azurerm_role_assignment.this : key => assignment.id
  }
}
