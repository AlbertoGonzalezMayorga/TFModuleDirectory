variable "nat_gateways" {
  description = "NAT gateways to create. Keys are NAT gateway names."

  type = map(object({
    resource_group_name     = string
    location                = string
    idle_timeout_in_minutes = optional(number, 4)
    zones                   = optional(list(string), null)
    subnet_ids              = optional(list(string), [])
    tags                    = optional(map(string), {})
  }))

  default = {}
}

variable "tags" {
  description = "Tags applied to all supported resources."
  type        = map(string)
  default     = {}
}
