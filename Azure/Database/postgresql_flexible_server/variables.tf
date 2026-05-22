variable "servers" {
  description = "PostgreSQL Flexible Servers to create. Keys are server names."

  type = map(object({
    resource_group_name           = string
    location                      = string
    version                       = optional(string, "16")
    administrator_login           = string
    administrator_password        = string
    sku_name                      = optional(string, "B_Standard_B1ms")
    storage_mb                    = optional(number, 32768)
    backup_retention_days         = optional(number, 7)
    geo_redundant_backup_enabled  = optional(bool, false)
    public_network_access_enabled = optional(bool, false)
    delegated_subnet_id           = optional(string, null)
    private_dns_zone_id           = optional(string, null)
    zone                          = optional(string, null)
    tags                          = optional(map(string), {})

    databases = optional(map(object({
      charset   = optional(string, "UTF8")
      collation = optional(string, "en_US.utf8")
    })), {})
  }))

  default = {}
}

variable "tags" {
  description = "Tags applied to all servers."
  type        = map(string)
  default     = {}
}
