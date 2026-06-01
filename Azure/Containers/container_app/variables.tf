variable "resource_group_name" {
  description = "Resource group name where the Container App is created."
  type        = string
}

variable "location" {
  description = "Azure region where the Container App is created."
  type        = string
}

variable "container_app_name" {
  description = "Container App name."
  type        = string
}

variable "create_container_app_environment" {
  description = "Whether to create a new Container App Environment. If false, an existing environment must be specified via container_app_environment_name."
  type        = bool
  default     = true
}

variable "container_app_environment_name" {
  description = "Container App Environment name. The name of an existing container_app_environment if create_container_app_environment is false, new environment name otherwise."
  type        = string
  default     = null
}

variable "revision_mode" {
  description = "Container App revision mode."
  type        = string
  default     = "Single"

  validation {
    condition     = contains(["Single", "Multiple"], var.revision_mode)
    error_message = "revision_mode must be Single or Multiple."
  }
}

variable "workload_profile_name" {
  description = "Optional workload profile name."
  type        = string
  default     = null
}

variable "container_name" {
  description = "Container name inside the Container App template."
  type        = string
  default     = "app"
}

variable "image" {
  description = "Container image. Defaults to the Azure Container Apps hello world image."
  type        = string
  default     = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
}

variable "cpu" {
  description = "Container CPU."
  type        = number
  default     = 0.25
}

variable "memory" {
  description = "Container memory."
  type        = string
  default     = "0.5Gi"
}

variable "command" {
  description = "Optional container command."
  type        = list(string)
  default     = null
}

variable "args" {
  description = "Optional container arguments."
  type        = list(string)
  default     = null
}

variable "env" {
  description = "Environment variables for the container, keyed by variable name."

  type = map(object({
    value       = optional(string)
    secret_name = optional(string)
  }))

  default = {}
}

variable "secrets" {
  description = "Container App secrets, keyed by secret name. Use either value for native Container App secrets or key_vault_secret_id plus identity for Key Vault references."

  type = map(object({
    value               = optional(string)
    key_vault_secret_id = optional(string)
    identity            = optional(string)
  }))

  default = {}

  validation {
    condition = alltrue([
      for secret in values(var.secrets) :
      (
        secret.value != null &&
        secret.key_vault_secret_id == null &&
        secret.identity == null
      ) ||
      (
        secret.value == null &&
        secret.key_vault_secret_id != null &&
        secret.identity != null
      )
    ])
    error_message = "Each secret must set either value, or both key_vault_secret_id and identity."
  }
}

variable "registries" {
  description = "Container registries used by the Container App, keyed by logical name."

  type = map(object({
    server               = string
    username             = optional(string)
    password_secret_name = optional(string)
    identity             = optional(string)
  }))

  default = {}
}

variable "ingress" {
  description = "Optional ingress configuration."

  type = object({
    external_enabled           = optional(bool, true)
    target_port                = number
    transport                  = optional(string, "auto")
    allow_insecure_connections = optional(bool, false)
    exposed_port               = optional(number)

    traffic_weight = optional(list(object({
      percentage      = number
      latest_revision = optional(bool)
      revision_suffix = optional(string)
      label           = optional(string)
    })), [])
  })

  default = null
}

variable "custom_domains" {
  description = "Custom domains to bind to the Container App, keyed by logical name."

  type = map(object({
    name                                     = string
    certificate_binding_type                 = optional(string, "SniEnabled")
    container_app_environment_certificate_id = optional(string)
  }))

  default = {}
}

variable "identity" {
  description = "Optional managed identity configuration."

  type = object({
    type         = string
    identity_ids = optional(list(string), [])
  })

  default = null
}

variable "min_replicas" {
  description = "Minimum number of replicas."
  type        = number
  default     = 0
}

variable "max_replicas" {
  description = "Maximum number of replicas."
  type        = number
  default     = 1
}

variable "tags" {
  description = "Tags applied to the Container App."
  type        = map(string)
  default     = {}
}
