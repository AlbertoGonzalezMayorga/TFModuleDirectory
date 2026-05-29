variable "create_key_vault" {
  description = "Whether to create a new Key Vault. Set to false to use an existing Key Vault."
  type        = bool
  default     = true
}

variable "name" {
  description = "Key Vault name. Required when create_key_vault is true."
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "Resource group name for the Key Vault. Required when create_key_vault is true."
  type        = string
  default     = null
}

variable "location" {
  description = "Azure region for the Key Vault. Required when create_key_vault is true."
  type        = string
  default     = null
}

variable "tenant_id" {
  description = "Tenant ID for the Key Vault. Defaults to the current Terraform client tenant."
  type        = string
  default     = null
}

variable "sku_name" {
  description = "Key Vault SKU."
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "sku_name must be standard or premium."
  }
}

variable "purge_protection_enabled" {
  description = "Whether purge protection is enabled for a created Key Vault."
  type        = bool
  default     = false
}

variable "soft_delete_retention_days" {
  description = "Soft delete retention in days for a created Key Vault."
  type        = number
  default     = 7
}

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled for a created Key Vault."
  type        = bool
  default     = true
}

variable "enabled_for_disk_encryption" {
  description = "Whether the created Key Vault is enabled for Azure Disk Encryption."
  type        = bool
  default     = false
}

variable "enable_rbac_authorization" {
  description = "Whether the Key Vault uses Azure RBAC for authorization. Access policies are skipped when true."
  type        = bool
  default     = false
}

variable "existing_key_vault" {
  description = "Existing Key Vault to use when create_key_vault is false."

  type = object({
    name                = string
    resource_group_name = string
  })

  default = null
}

variable "access_policies" {
  description = "Access policies to create when enable_rbac_authorization is false, keyed by logical name."

  type = map(object({
    tenant_id               = optional(string)
    object_id               = string
    application_id          = optional(string)
    key_permissions         = optional(list(string), [])
    secret_permissions      = optional(list(string), [])
    certificate_permissions = optional(list(string), [])
    storage_permissions     = optional(list(string), [])
  }))

  default = {}
}

variable "enable_current_client_secret_permissions" {
  description = "Whether to add an access policy for the current Terraform client to manage secrets."
  type        = bool
  default     = true
}

variable "current_client_secret_permissions" {
  description = "Secret permissions granted to the current Terraform client when enabled."
  type        = list(string)
  default     = ["Get", "List", "Set", "Delete", "Recover", "Purge"]
}

variable "secrets" {
  description = "Secrets to create in the effective Key Vault, keyed by secret name."

  type = map(object({
    name         = optional(string)
    value        = string
    content_type = optional(string)
    tags         = optional(map(string), {})
  }))

  default = {}
}

variable "tags" {
  description = "Tags applied to supported resources unless overridden per secret."
  type        = map(string)
  default     = {}
}
