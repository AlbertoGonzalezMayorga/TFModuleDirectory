variable "registries" {
  description = "Azure Container Registries to create. Keys are registry names."

  type = map(object({
    resource_group_name           = string
    location                      = string
    sku                           = optional(string, "Standard")
    admin_enabled                 = optional(bool, false)
    public_network_access_enabled = optional(bool, true)
    zone_redundancy_enabled       = optional(bool, false)
    tags                          = optional(map(string), {})

    georeplications = optional(list(object({
      location                = string
      zone_redundancy_enabled = optional(bool, false)
      tags                    = optional(map(string), {})
    })), [])
  }))

  default = {}

  validation {
    condition     = alltrue([for registry in values(var.registries) : contains(["Basic", "Standard", "Premium"], registry.sku)])
    error_message = "ACR sku must be Basic, Standard, or Premium."
  }
}

variable "tags" {
  description = "Tags applied to all registries."
  type        = map(string)
  default     = {}
}
