variable "name" {
  description = "Application Insights component name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name where Application Insights is created."
  type        = string
}

variable "location" {
  description = "Azure region where Application Insights is created."
  type        = string
}

variable "application_type" {
  description = "Application Insights application type."
  type        = string
  default     = "web"

  validation {
    condition     = contains(["ios", "java", "MobileCenter", "Node.JS", "other", "phone", "store", "web"], var.application_type)
    error_message = "application_type must be one of ios, java, MobileCenter, Node.JS, other, phone, store, or web."
  }
}

variable "workspace_id" {
  description = "Optional Log Analytics Workspace ID for workspace-based Application Insights."
  type        = string
  default     = null
}

variable "retention_in_days" {
  description = "Retention period in days."
  type        = number
  default     = 90
}

variable "daily_data_cap_in_gb" {
  description = "Daily data volume cap in GB."
  type        = number
  default     = null
}

variable "daily_data_cap_notifications_disabled" {
  description = "Whether daily data cap notifications are disabled."
  type        = bool
  default     = null
}

variable "sampling_percentage" {
  description = "Sampling percentage for ingested telemetry."
  type        = number
  default     = null
}

variable "disable_ip_masking" {
  description = "Whether IP masking is disabled."
  type        = bool
  default     = false
}

variable "local_authentication_disabled" {
  description = "Whether local authentication is disabled."
  type        = bool
  default     = false
}

variable "internet_ingestion_enabled" {
  description = "Whether telemetry ingestion from the public internet is enabled."
  type        = bool
  default     = true
}

variable "internet_query_enabled" {
  description = "Whether querying from the public internet is enabled."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to Application Insights."
  type        = map(string)
  default     = {}
}
