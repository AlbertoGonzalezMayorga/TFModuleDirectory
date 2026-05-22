variable "profiles" {
  description = "Azure Front Door profiles to create. Keys are profile names."

  type = map(object({
    resource_group_name = string
    sku_name            = optional(string, "Standard_AzureFrontDoor")
    tags                = optional(map(string), {})

    endpoints = map(object({
      enabled = optional(bool, true)
      tags    = optional(map(string), {})
    }))

    origin_groups = map(object({
      session_affinity_enabled = optional(bool, false)
      origins = map(object({
        host_name                      = string
        http_port                      = optional(number, 80)
        https_port                     = optional(number, 443)
        origin_host_header             = optional(string, null)
        certificate_name_check_enabled = optional(bool, true)
        priority                       = optional(number, 1)
        weight                         = optional(number, 1000)
        enabled                        = optional(bool, true)
      }))
    }))

    routes = map(object({
      endpoint_key           = string
      origin_group_key       = string
      origin_keys            = list(string)
      enabled                = optional(bool, true)
      forwarding_protocol    = optional(string, "HttpsOnly")
      https_redirect_enabled = optional(bool, true)
      patterns_to_match      = optional(list(string), ["/*"])
      supported_protocols    = optional(list(string), ["Http", "Https"])
    }))
  }))

  default = {}
}

variable "tags" {
  description = "Tags applied to all supported resources."
  type        = map(string)
  default     = {}
}
