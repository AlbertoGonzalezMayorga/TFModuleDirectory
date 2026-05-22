variable "role_assignments" {
  description = "Map of RBAC assignments. The key of the map must be unique."
  type = map(object({
    scope                            = string                # The scope of the role assignment, e.g. id of a resource group or a specific resource.
    principal_id                     = string                # The object ID of the principal (user, group, or service principal) to which the role will be assigned.
    role_definition_name             = optional(string)      # The name of the role definition to assign.
    role_definition_id               = optional(string)      # The ID of the role definition to assign.
    principal_type                   = optional(string)      # The type of the principal (User, Group, or ServicePrincipal).
    skip_service_principal_aad_check = optional(bool, false) # Whether to skip the AAD check for service principals.
  }))

  validation {
    condition = alltrue([
      for _, ra in var.role_assignments :
      (try(ra.role_definition_name, null) != null) != (try(ra.role_definition_id, null) != null)
    ])
    error_message = "Each assignment must have exactly one: role_definition_name or role_definition_id."
  }
}
