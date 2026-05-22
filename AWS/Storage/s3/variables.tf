variable "buckets" {
  description = "S3 buckets to create. Keys are bucket names."

  type = map(object({
    force_destroy     = optional(bool, false)
    versioning_status = optional(string, "Enabled")
    tags              = optional(map(string), {})

    public_access_block = optional(object({
      block_public_acls       = optional(bool, true)
      block_public_policy     = optional(bool, true)
      ignore_public_acls      = optional(bool, true)
      restrict_public_buckets = optional(bool, true)
    }), {})

    server_side_encryption = optional(object({
      sse_algorithm      = optional(string, "AES256")
      kms_master_key_id  = optional(string, null)
      bucket_key_enabled = optional(bool, true)
    }), {})

    logging = optional(object({
      target_bucket = string
      target_prefix = optional(string, "logs/")
    }), null)

    lifecycle_rules = optional(list(object({
      id                                     = string
      status                                 = optional(string, "Enabled")
      prefix                                 = optional(string, "")
      transition                             = optional(object({ days = number, storage_class = string }), null)
      expiration_days                        = optional(number, null)
      abort_incomplete_multipart_upload_days = optional(number, null)
    })), [])
  }))

  default = {}
}

variable "tags" {
  description = "Tags applied to all buckets."
  type        = map(string)
  default     = {}
}
