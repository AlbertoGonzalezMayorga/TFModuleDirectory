variable "clusters" {
  description = "AKS clusters to create. Keys are cluster names."

  type = map(object({
    resource_group_name               = string
    location                          = string
    dns_prefix                        = string
    kubernetes_version                = optional(string, null)
    private_cluster_enabled           = optional(bool, false)
    role_based_access_control_enabled = optional(bool, true)
    sku_tier                          = optional(string, "Free")
    identity_type                     = optional(string, "SystemAssigned")
    tags                              = optional(map(string), {})

    default_node_pool = object({
      name                 = optional(string, "system")
      vm_size              = optional(string, "Standard_D2s_v5")
      node_count           = optional(number, 2)
      auto_scaling_enabled = optional(bool, true)
      min_count            = optional(number, 1)
      max_count            = optional(number, 3)
      vnet_subnet_id       = optional(string, null)
      zones                = optional(list(string), null)
    })

    network_profile = optional(object({
      network_plugin    = optional(string, "azure")
      network_policy    = optional(string, "azure")
      load_balancer_sku = optional(string, "standard")
      service_cidr      = optional(string, null)
      dns_service_ip    = optional(string, null)
      outbound_type     = optional(string, "loadBalancer")
    }), {})

    node_pools = optional(map(object({
      vm_size              = optional(string, "Standard_D2s_v5")
      node_count           = optional(number, 1)
      auto_scaling_enabled = optional(bool, true)
      min_count            = optional(number, 1)
      max_count            = optional(number, 3)
      mode                 = optional(string, "User")
      vnet_subnet_id       = optional(string, null)
      zones                = optional(list(string), null)
      node_labels          = optional(map(string), {})
      tags                 = optional(map(string), {})
    })), {})
  }))

  default = {}
}

variable "tags" {
  description = "Tags applied to all supported resources."
  type        = map(string)
  default     = {}
}
