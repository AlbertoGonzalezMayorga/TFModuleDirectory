variable "virtual_networks" {
  description = "Virtual networks to create. Keys are VNet names."

  type = map(object({
    resource_group_name = string
    location            = string
    address_space       = list(string)
    dns_servers         = optional(list(string), null)
    tags                = optional(map(string), {})

    subnets = optional(map(object({
      address_prefixes  = list(string)
      service_endpoints = optional(list(string), [])
    })), {})
  }))

  default = {}
}

variable "tags" {
  description = "Tags applied to all supported resources."
  type        = map(string)
  default     = {}
}
