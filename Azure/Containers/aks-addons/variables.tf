variable "cluster_id" {
  description = "AKS cluster resource ID where extensions are installed."
  type        = string
}

variable "extensions" {
  description = "AKS cluster extensions to install, keyed by extension name."

  type = map(object({
    extension_type                   = string
    release_train                    = optional(string)
    version                          = optional(string)
    target_namespace                 = optional(string)
    configuration_settings           = optional(map(string), {})
    configuration_protected_settings = optional(map(string), {})

    plan = optional(object({
      name      = string
      product   = string
      publisher = string
      version   = optional(string)
    }))
  }))

  default = {}
}
