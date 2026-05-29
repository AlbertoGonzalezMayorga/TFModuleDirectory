variable "releases" {
  description = "Helm releases to install, keyed by logical name."

  type = map(object({
    name             = string
    repository       = optional(string)
    chart            = string
    chart_version    = optional(string)
    namespace        = string
    create_namespace = optional(bool, true)
    values           = optional(any, {})
    timeout          = optional(number, 600)
    atomic           = optional(bool, true)
    wait             = optional(bool, true)
  }))

  default = {}
}

variable "extra_manifests" {
  description = "Additional Kubernetes manifests to apply after Helm releases, keyed by logical name."

  type = map(any)

  default = {}
}
