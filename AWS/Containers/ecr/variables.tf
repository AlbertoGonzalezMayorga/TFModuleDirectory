### Repository Selection

variable "repositories" {
  description = "Map of ECR repositories to create. Each repository is the ECR container for images and artifacts. Keys are repository names and values override module defaults per repository."

  type = map(object({
    encryption_kms_key   = optional(string)
    encryption_type      = optional(string)
    force_delete         = optional(bool)
    image_tag_mutability = optional(string)
    lifecycle_policy     = optional(string)
    repository_policy    = optional(string)
    scan_on_push         = optional(bool)
    tag_mutability_filters = optional(list(object({
      filter      = string
      filter_type = string
    })))
    tags = optional(map(string), {})
  }))

  default = {}

  validation {
    condition = alltrue([
      for name in keys(var.repositories) :
      can(regex("^(?:[a-z0-9]+(?:(?:[._-][a-z0-9]+)+)?/)*[a-z0-9]+(?:(?:[._-][a-z0-9]+)+)?$", name))
    ])
    error_message = "Each repositories key must be a valid ECR repository name using lowercase letters, numbers, separators '.', '_' or '-', and optional namespace paths separated by '/'."
  }

}

### Defaults

variable "tags" {
  description = "Tags applied to all repositories."
  type        = map(string)
  default     = {}
}

variable "force_delete" {
  description = "Whether to delete the repository even if it contains images."
  type        = bool
  default     = false
}

variable "image_tag_mutability" {
  description = "Tag mutability setting for repositories."
  type        = string
  default     = "IMMUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE", "IMMUTABLE_WITH_EXCLUSION", "MUTABLE_WITH_EXCLUSION"], var.image_tag_mutability)
    error_message = "image_tag_mutability must be MUTABLE, IMMUTABLE, IMMUTABLE_WITH_EXCLUSION, or MUTABLE_WITH_EXCLUSION."
  }
}

variable "tag_mutability_filters" {
  description = "Default exclusion filters used with *_WITH_EXCLUSION image tag mutability modes."

  type = list(object({
    filter      = string
    filter_type = string
  }))

  default = []

  validation {
    condition = alltrue([
      for filter in var.tag_mutability_filters :
      contains(["WILDCARD"], filter.filter_type)
    ])
    error_message = "tag_mutability_filters filter_type currently supports WILDCARD."
  }
}

variable "scan_on_push" {
  description = "Whether ECR scans images after they are pushed."
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "Encryption type for the repository."
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_type)
    error_message = "encryption_type must be AES256 or KMS."
  }
}

variable "encryption_kms_key" {
  description = "KMS key ARN or alias used when encryption_type is KMS."
  type        = string
  default     = null
}

variable "lifecycle_policy" {
  description = "Default lifecycle policy JSON. Set null to skip lifecycle policy creation."
  type        = string
  default     = null
}
