variable "cluster_name" {
  description = "Name of the EKS cluster where add-ons are installed."
  type        = string
}

variable "oidc_provider_arn" {
  description = "IAM OpenID Connect provider ARN used for IRSA roles."
  type        = string
  default     = null
}

variable "oidc_issuer_url" {
  description = "EKS cluster OIDC issuer URL used for IRSA trust policies."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to supported resources."
  type        = map(string)
  default     = {}
}

variable "addons" {
  description = "EKS managed add-ons to install, keyed by add-on name."

  type = map(object({
    addon_version               = optional(string)
    configuration_values        = optional(string)
    preserve                    = optional(bool, true)
    resolve_conflicts_on_create = optional(string, "OVERWRITE")
    resolve_conflicts_on_update = optional(string, "OVERWRITE")
    service_account_role_arn    = optional(string)
    tags                        = optional(map(string), {})

    pod_identity_associations = optional(list(object({
      role_arn        = string
      service_account = string
    })), [])

    irsa = optional(object({
      namespace            = string
      service_account      = string
      policy_arns          = optional(list(string), [])
      role_name            = optional(string)
      role_name_prefix     = optional(string)
      permissions_boundary = optional(string)
      tags                 = optional(map(string), {})
    }))
  }))

  default = {}

  validation {
    condition = alltrue(flatten([
      for addon in values(var.addons) : [
        contains(["NONE", "OVERWRITE"], addon.resolve_conflicts_on_create),
        contains(["NONE", "OVERWRITE", "PRESERVE"], addon.resolve_conflicts_on_update)
      ]
    ]))
    error_message = "resolve_conflicts_on_create must be NONE or OVERWRITE. resolve_conflicts_on_update must be NONE, OVERWRITE, or PRESERVE."
  }

  validation {
    condition = alltrue([
      for addon in values(var.addons) :
      addon.irsa == null || addon.service_account_role_arn == null
    ])
    error_message = "Set either irsa or service_account_role_arn for an add-on, not both."
  }
}
