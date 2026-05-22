variable "storage_accounts" {
  description = "Storage accounts to create. Keys are storage account names."

  type = map(object({
    resource_group_name             = string
    location                        = string
    account_tier                    = optional(string, "Standard")
    account_replication_type        = optional(string, "LRS")
    account_kind                    = optional(string, "StorageV2")
    access_tier                     = optional(string, "Hot")
    allow_nested_items_to_be_public = optional(bool, false)
    min_tls_version                 = optional(string, "TLS1_2")
    public_network_access_enabled   = optional(bool, true)
    shared_access_key_enabled       = optional(bool, true)
    blob_versioning_enabled         = optional(bool, true)
    blob_delete_retention_days      = optional(number, 7)
    container_delete_retention_days = optional(number, 7)
    tags                            = optional(map(string), {})

    containers = optional(map(object({
      container_access_type = optional(string, "private")
    })), {})
  }))

  default = {}
}

variable "tags" {
  description = "Tags applied to all storage accounts."
  type        = map(string)
  default     = {}
}
