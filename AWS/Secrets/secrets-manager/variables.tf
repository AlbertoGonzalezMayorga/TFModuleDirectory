variable "tags" {
  description = "Tags applied to all Secrets Manager secrets unless overridden per secret."
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "AWS Secrets Manager secrets to create, keyed by secret name."

  type = map(object({
    description             = optional(string)
    secret_string           = optional(map(string), {})
    kms_key_id              = optional(string)
    recovery_window_in_days = optional(number, 7)
    tags                    = optional(map(string), {})
  }))

  default = {}
}
