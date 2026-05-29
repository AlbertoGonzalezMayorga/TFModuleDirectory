variable "tags" {
  description = "Tags applied to all supported resources unless overridden per identity."
  type        = map(string)
  default     = {}
}

variable "identities" {
  description = "User-assigned managed identities to create, keyed by a stable logical name."

  type = map(object({
    name                = optional(string)
    resource_group_name = string
    location            = string
    tags                = optional(map(string), {})

    federated_credentials = optional(map(object({
      name     = optional(string)
      issuer   = string
      subject  = string
      audience = optional(list(string), ["api://AzureADTokenExchange"])
    })), {})

    role_assignments = optional(map(object({
      scope                                  = string
      role_definition_name                   = optional(string)
      role_definition_id                     = optional(string)
      principal_type                         = optional(string, "ServicePrincipal")
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string)
      condition_version                      = optional(string)
      delegated_managed_identity_resource_id = optional(string)
    })), {})
  }))

  default = {}

  validation {
    condition = alltrue(flatten([
      for identity in values(var.identities) : [
        for assignment in values(coalesce(identity.role_assignments, {})) :
        (assignment.role_definition_name != null) != (assignment.role_definition_id != null)
      ]
    ]))
    error_message = "Each role assignment must set exactly one of role_definition_name or role_definition_id."
  }
}
