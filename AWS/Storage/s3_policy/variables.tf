variable "bucket" {
  description = "Bucket name or ID."
  type        = string
}

variable "source_policy_documents" {
  description = "Source policy documents to merge."
  type        = list(string)
  default     = []
}

variable "override_policy_documents" {
  description = "Override policy documents to merge."
  type        = list(string)
  default     = []
}

variable "statements" {
  description = "Policy statements to include."
  type = list(object({
    sid       = optional(string, null)
    effect    = optional(string, "Allow")
    actions   = list(string)
    resources = list(string)
    principals = optional(list(object({
      type        = string
      identifiers = list(string)
    })), [])
    conditions = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })), [])
  }))
  default = []
}
