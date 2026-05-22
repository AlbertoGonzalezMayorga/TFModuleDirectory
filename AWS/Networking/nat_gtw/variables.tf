variable "nat_gateways" {
  description = "NAT gateways to create. Keys are friendly names."
  type = map(object({
    subnet_id              = string
    route_table_ids        = optional(list(string), [])
    destination_cidr_block = optional(string, "0.0.0.0/0")
    tags                   = optional(map(string), {})
  }))
  default = {}
}

variable "tags" {
  description = "Tags applied to all supported resources."
  type        = map(string)
  default     = {}
}
