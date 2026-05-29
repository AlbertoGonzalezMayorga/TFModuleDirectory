variable "name" {
  description = "Log Analytics Workspace name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name where the workspace is created."
  type        = string
}

variable "location" {
  description = "Azure region where the workspace is created."
  type        = string
}

variable "sku" {
  description = "Log Analytics Workspace SKU."
  type        = string
  default     = "PerGB2018"
}

variable "retention_in_days" {
  description = "Data retention period in days."
  type        = number
  default     = 30
}

variable "daily_quota_gb" {
  description = "Daily ingestion quota in GB."
  type        = number
  default     = -1
}

variable "internet_ingestion_enabled" {
  description = "Whether ingestion from the public internet is enabled."
  type        = bool
  default     = true
}

variable "internet_query_enabled" {
  description = "Whether querying from the public internet is enabled."
  type        = bool
  default     = true
}

variable "reservation_capacity_in_gb_per_day" {
  description = "Reservation capacity in GB per day for capacity reservation SKUs."
  type        = number
  default     = null
}

variable "allow_resource_only_permissions" {
  description = "Whether resource-context permissions are allowed."
  type        = bool
  default     = true
}

variable "local_authentication_disabled" {
  description = "Whether local authentication is disabled."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to the workspace."
  type        = map(string)
  default     = {}
}
