variable "tags" {
  description = "Tags applied to all IAM roles unless overridden per role."
  type        = map(string)
  default     = {}
}

variable "roles" {
  description = "IAM roles to create, keyed by a stable logical name."

  type = map(object({
    name                  = optional(string)
    name_prefix           = optional(string)
    path                  = optional(string, "/")
    description           = optional(string)
    permissions_boundary  = optional(string)
    max_session_duration  = optional(number, 3600)
    force_detach_policies = optional(bool, false)

    assume_role_policy = optional(string)

    irsa = optional(object({
      oidc_provider_arn = string
      oidc_issuer_url   = string
      namespace         = string
      service_account   = string
      audience          = optional(string, "sts.amazonaws.com")
    }))

    inline_policies     = optional(map(string), {})
    managed_policy_arns = optional(list(string), [])
    tags                = optional(map(string), {})
  }))

  default = {}

  validation {
    condition = alltrue([
      for role in values(var.roles) :
      (role.assume_role_policy != null) != (role.irsa != null)
    ])
    error_message = "Each role must set exactly one of assume_role_policy or irsa."
  }
}
