variable "application_gateways" {
  description = "Application Gateways to create. Keys are gateway names."

  type = map(object({
    resource_group_name  = string
    location             = string
    subnet_id            = string
    sku_name             = optional(string, "Standard_v2")
    sku_tier             = optional(string, "Standard_v2")
    capacity             = optional(number, 1)
    create_public_ip     = optional(bool, true)
    public_ip_address_id = optional(string, null)
    zones                = optional(list(string), null)
    backend_fqdns        = optional(list(string), [])
    backend_port         = optional(number, 80)
    backend_protocol     = optional(string, "Http")
    request_timeout      = optional(number, 30)
    tags                 = optional(map(string), {})
  }))

  default = {}
}

variable "tags" {
  description = "Tags applied to all supported resources."
  type        = map(string)
  default     = {}
}
