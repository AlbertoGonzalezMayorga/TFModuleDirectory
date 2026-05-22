variable "service_plans" {
  description = "App Service plans to create. Keys are plan names."

  type = map(object({
    resource_group_name = string
    location            = string
    os_type             = optional(string, "Linux")
    sku_name            = optional(string, "B1")
    tags                = optional(map(string), {})
  }))

  default = {}
}

variable "linux_web_apps" {
  description = "Linux Web Apps to create. Keys are app names."

  type = map(object({
    resource_group_name = string
    location            = string
    service_plan_key    = string
    https_only          = optional(bool, true)
    always_on           = optional(bool, true)
    app_settings        = optional(map(string), {})
    docker_image_name   = optional(string, null)
    docker_registry_url = optional(string, null)
    identity_type       = optional(string, "SystemAssigned")
    tags                = optional(map(string), {})
  }))

  default = {}
}

variable "tags" {
  description = "Tags applied to all supported resources."
  type        = map(string)
  default     = {}
}
