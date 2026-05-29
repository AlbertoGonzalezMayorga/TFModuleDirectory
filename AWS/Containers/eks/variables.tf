### Project

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string

  validation {
    condition     = length(var.cluster_name) <= 100 && can(regex("^[0-9A-Za-z][A-Za-z0-9\\-_]*$", var.cluster_name))
    error_message = "cluster_name must be 100 characters or fewer and match ^[0-9A-Za-z][A-Za-z0-9\\-_]*$."
  }
}

variable "tags" {
  description = "Tags applied to all supported resources."
  type        = map(string)
  default     = {}
}


### Cluster

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster. Set null to let AWS use its default."
  type        = string
  default     = null
}

variable "cluster_mode" {
  description = "EKS cluster mode. Use auto for EKS Auto Mode or classic for EKS managed node groups."
  type        = string
  default     = "auto"

  validation {
    condition     = contains(["auto", "classic"], var.cluster_mode)
    error_message = "cluster_mode must be either auto or classic."
  }
}

variable "authentication_mode" {
  description = "EKS access authentication mode."
  type        = string
  default     = "API_AND_CONFIG_MAP"

  validation {
    condition     = contains(["API", "CONFIG_MAP", "API_AND_CONFIG_MAP"], var.authentication_mode)
    error_message = "authentication_mode must be API, CONFIG_MAP, or API_AND_CONFIG_MAP."
  }
}

variable "bootstrap_cluster_creator_admin_permissions" {
  description = "Whether to grant cluster-admin access to the IAM principal creating the cluster."
  type        = bool
  default     = true
}

variable "bootstrap_self_managed_addons" {
  description = "Whether EKS should bootstrap the default self-managed add-ons during cluster creation. Ignored in auto mode, where it is forced to false."
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Whether deletion protection is enabled for the EKS cluster."
  type        = bool
  default     = false
}

variable "enabled_cluster_log_types" {
  description = "Control plane log types to enable."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for log_type in var.enabled_cluster_log_types :
      contains(["api", "audit", "authenticator", "controllerManager", "scheduler"], log_type)
    ])
    error_message = "enabled_cluster_log_types can contain api, audit, authenticator, controllerManager, and scheduler."
  }
}

variable "encryption_config" {
  description = "Cluster encryption configuration for Kubernetes secrets."

  type = object({
    kms_key_arn = string
    resources   = optional(list(string), ["secrets"])
  })

  default = null
}

variable "upgrade_policy" {
  description = "EKS upgrade support policy."

  type = object({
    support_type = string
  })

  default = null

  validation {
    condition     = var.upgrade_policy == null || contains(["STANDARD", "EXTENDED"], var.upgrade_policy.support_type)
    error_message = "upgrade_policy.support_type must be STANDARD or EXTENDED."
  }
}


### Networking

variable "subnet_ids" {
  description = "Existing subnet IDs where the EKS cluster and managed node groups will run. Required unless create_subnets is true."
  type        = list(string)
  default     = []
}

variable "create_subnets" {
  description = "Whether this module should create subnets in vpc_id from vpc_cidr."
  type        = bool
  default     = false

  validation {
    condition     = var.create_subnets || length(var.subnet_ids) > 0
    error_message = "subnet_ids must contain at least one subnet unless create_subnets is true."
  }

  validation {
    condition     = !var.create_subnets || (var.vpc_id != null && var.vpc_cidr != null)
    error_message = "vpc_id and vpc_cidr are required when create_subnets is true."
  }
}

variable "vpc_id" {
  description = "VPC ID used when create_subnets is true."
  type        = string
  default     = null
}

variable "vpc_cidr" {
  description = "Parent VPC CIDR used to generate subnets when create_subnets is true."
  type        = string
  default     = null
}

variable "subnet_count" {
  description = "Number of subnets to create when create_subnets is true."
  type        = number
  default     = 3
}

variable "subnet_name_suffix" {
  description = "Suffix used for generated subnet Name tags."
  type        = string
  default     = "subnet"
}

variable "subnet_tags" {
  description = "Additional tags applied to generated subnets."
  type        = map(string)
  default     = {}
}

variable "map_public_ip_on_launch" {
  description = "Whether generated subnets map public IPs on launch."
  type        = bool
  default     = false
}

variable "cluster_security_group_ids" {
  description = "Additional security group IDs attached to the EKS cluster control plane."
  type        = list(string)
  default     = []
}

variable "endpoint_private_access" {
  description = "Whether the private API server endpoint is enabled."
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Whether the public API server endpoint is enabled."
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "CIDR blocks that can access the public API server endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ip_family" {
  description = "IP family for the Kubernetes network."
  type        = string
  default     = "ipv4"

  validation {
    condition     = contains(["ipv4", "ipv6"], var.ip_family)
    error_message = "ip_family must be ipv4 or ipv6."
  }
}

variable "service_ipv4_cidr" {
  description = "Kubernetes service IPv4 CIDR. Only valid when ip_family is ipv4."
  type        = string
  default     = null
}

variable "service_ipv6_cidr" {
  description = "Kubernetes service IPv6 CIDR. Only valid when ip_family is ipv6."
  type        = string
  default     = null
}


### IAM

variable "create_cluster_iam_role" {
  description = "Whether to create the EKS cluster IAM role."
  type        = bool
  default     = true

  validation {
    condition     = var.create_cluster_iam_role || var.cluster_iam_role_arn != null
    error_message = "cluster_iam_role_arn is required when create_cluster_iam_role is false."
  }
}

variable "cluster_iam_role_arn" {
  description = "Existing EKS cluster IAM role ARN. Required when create_cluster_iam_role is false."
  type        = string
  default     = null
}

variable "cluster_iam_role_name" {
  description = "Name for the created cluster IAM role. If null, cluster_iam_role_name_prefix is used."
  type        = string
  default     = null
}

variable "cluster_iam_role_name_prefix" {
  description = "Name prefix for the created cluster IAM role."
  type        = string
  default     = "eks-cluster-"
}

variable "cluster_iam_role_permissions_boundary" {
  description = "Permissions boundary ARN for the created cluster IAM role."
  type        = string
  default     = null
}

variable "cluster_additional_policy_arns" {
  description = "Additional policy ARNs attached to the created cluster IAM role."
  type        = list(string)
  default     = []
}

variable "create_oidc_provider" {
  description = "Whether to create an IAM OpenID Connect provider for this cluster."
  type        = bool
  default     = true
}

variable "oidc_provider_arn" {
  description = "Existing IAM OpenID Connect provider ARN. Required when create_oidc_provider is false and IRSA consumers need it."
  type        = string
  default     = null
}

variable "create_node_iam_role" {
  description = "Whether to create the EKS node IAM role."
  type        = bool
  default     = true

  validation {
    condition     = var.create_node_iam_role || var.node_iam_role_arn != null
    error_message = "node_iam_role_arn is required when create_node_iam_role is false."
  }
}

variable "node_iam_role_arn" {
  description = "Existing EKS node IAM role ARN. Required when create_node_iam_role is false."
  type        = string
  default     = null
}

variable "node_iam_role_name" {
  description = "Name for the created node IAM role. If null, node_iam_role_name_prefix is used."
  type        = string
  default     = null
}

variable "node_iam_role_name_prefix" {
  description = "Name prefix for the created node IAM role."
  type        = string
  default     = "eks-node-"
}

variable "node_iam_role_permissions_boundary" {
  description = "Permissions boundary ARN for the created node IAM role."
  type        = string
  default     = null
}

variable "node_additional_policy_arns" {
  description = "Additional policy ARNs attached to the created node IAM role."
  type        = list(string)
  default     = []
}


### EKS Auto Mode

variable "auto_compute_config_enabled" {
  description = "Whether EKS Auto Mode compute is enabled."
  type        = bool
  default     = true
}

variable "auto_node_pools" {
  description = "Built-in EKS Auto Mode node pools to enable."
  type        = list(string)
  default     = ["system", "general-purpose"]

  validation {
    condition     = alltrue([for node_pool in var.auto_node_pools : contains(["system", "general-purpose"], node_pool)])
    error_message = "auto_node_pools can only contain system and general-purpose."
  }
}

variable "auto_elastic_load_balancing_enabled" {
  description = "Whether EKS Auto Mode manages load balancing."
  type        = bool
  default     = true
}

variable "auto_block_storage_enabled" {
  description = "Whether EKS Auto Mode manages block storage."
  type        = bool
  default     = true
}


### Classic Managed Node Groups

variable "node_count" {
  description = "Default desired node count for the default managed node group."
  type        = number
  default     = 3
}

variable "min_node_count" {
  description = "Default minimum node count for the default managed node group."
  type        = number
  default     = 2
}

variable "max_node_count" {
  description = "Default maximum node count for the default managed node group."
  type        = number
  default     = 4
}

variable "node_group_defaults" {
  description = "Defaults used by managed node groups."
  type = object({
    ami_type                   = optional(string, "AL2023_x86_64_STANDARD")
    capacity_type              = optional(string, "ON_DEMAND")
    disk_size                  = optional(number, 20)
    force_update_version       = optional(bool, null)
    instance_types             = optional(list(string), ["t3.medium"])
    kubernetes_version         = optional(string, null)
    labels                     = optional(map(string), {})
    launch_template            = optional(object({ id = optional(string), name = optional(string), version = optional(string) }), null)
    max_unavailable            = optional(number, 1)
    max_unavailable_percentage = optional(number, null)
    node_repair_enabled        = optional(bool, null)
    release_version            = optional(string, null)
    remote_access              = optional(object({ ec2_ssh_key = string, source_security_group_ids = optional(list(string), []) }), null)
    taints                     = optional(list(object({ effect = string, key = string, value = optional(string) })), [])
  })

  default = {}
}

variable "managed_node_groups" {
  description = "EKS managed node groups to create when cluster_mode is classic. If empty, one default node group is created."

  type = map(object({
    ami_type                   = optional(string)
    capacity_type              = optional(string)
    desired_size               = optional(number)
    disk_size                  = optional(number)
    force_update_version       = optional(bool)
    instance_types             = optional(list(string))
    kubernetes_version         = optional(string)
    labels                     = optional(map(string))
    launch_template            = optional(object({ id = optional(string), name = optional(string), version = optional(string) }))
    max_size                   = optional(number)
    max_unavailable            = optional(number)
    max_unavailable_percentage = optional(number)
    min_size                   = optional(number)
    node_repair_enabled        = optional(bool)
    release_version            = optional(string)
    remote_access              = optional(object({ ec2_ssh_key = string, source_security_group_ids = optional(list(string), []) }))
    subnet_ids                 = optional(list(string))
    tags                       = optional(map(string), {})
    taints                     = optional(list(object({ effect = string, key = string, value = optional(string) })), [])
  }))

  default = {}
}


### Access Entries

variable "access_entries" {
  description = "EKS access entries and policy associations, keyed by a friendly name."

  type = map(object({
    principal_arn     = string
    type              = optional(string, "STANDARD")
    kubernetes_groups = optional(list(string), null)
    user_name         = optional(string, null)
    tags              = optional(map(string), {})

    policy_associations = optional(map(object({
      policy_arn = string
      access_scope = object({
        type       = string
        namespaces = optional(list(string), null)
      })
    })), {})
  }))

  default = {}
}
