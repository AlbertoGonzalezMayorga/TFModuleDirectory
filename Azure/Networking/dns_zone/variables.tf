variable "zones" {
  description = "DNS zones to create. Keys are friendly names."

  type = map(object({
    name                = string
    resource_group_name = string
    private             = optional(bool, false)
    tags                = optional(map(string), {})
  }))

  default = {}
}

variable "tags" {
  description = "Tags applied to DNS zones."
  type        = map(string)
  default     = {}
}
