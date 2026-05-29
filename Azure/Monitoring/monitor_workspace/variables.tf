variable "name" {
  description = "Azure Monitor Workspace name."
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

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to the workspace."
  type        = map(string)
  default     = {}
}
