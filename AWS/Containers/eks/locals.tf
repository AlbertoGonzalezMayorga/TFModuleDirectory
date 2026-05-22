locals {
  cluster_role_arn = var.create_cluster_iam_role ? aws_iam_role.cluster[0].arn : var.cluster_iam_role_arn
  node_role_arn    = var.create_node_iam_role ? aws_iam_role.node[0].arn : var.node_iam_role_arn

  parent_prefix           = var.create_subnets ? tonumber(split("/", var.vpc_cidr)[1]) : 0
  subnet_newbits          = var.create_subnets ? ceil(log(var.subnet_count, 2)) : 0
  generated_subnet_prefix = local.parent_prefix + local.subnet_newbits

  generated_subnet_cidrs = var.create_subnets ? [
    for i in range(var.subnet_count) :
    cidrsubnet(var.vpc_cidr, local.subnet_newbits, i)
  ] : []

  cluster_subnet_ids = var.create_subnets ? aws_subnet.this[*].id : var.subnet_ids

  default_managed_node_group = var.cluster_mode == "classic" && length(var.managed_node_groups) == 0 ? {
    default = {
      desired_size = var.node_count
      max_size     = var.max_node_count
      min_size     = var.min_node_count
    }
  } : {}

  managed_node_groups = var.cluster_mode == "classic" ? {
    for name, node_group in merge(local.default_managed_node_group, var.managed_node_groups) : name => {
      ami_type                   = try(node_group.ami_type, var.node_group_defaults.ami_type)
      capacity_type              = try(node_group.capacity_type, var.node_group_defaults.capacity_type)
      desired_size               = try(node_group.desired_size, var.node_count)
      disk_size                  = try(node_group.disk_size, var.node_group_defaults.disk_size)
      force_update_version       = try(node_group.force_update_version, var.node_group_defaults.force_update_version)
      instance_types             = try(node_group.instance_types, var.node_group_defaults.instance_types)
      kubernetes_version         = try(node_group.kubernetes_version, var.node_group_defaults.kubernetes_version)
      labels                     = try(node_group.labels, var.node_group_defaults.labels)
      launch_template            = try(node_group.launch_template, var.node_group_defaults.launch_template)
      max_size                   = try(node_group.max_size, var.max_node_count)
      max_unavailable            = try(node_group.max_unavailable, var.node_group_defaults.max_unavailable)
      max_unavailable_percentage = try(node_group.max_unavailable_percentage, var.node_group_defaults.max_unavailable_percentage)
      min_size                   = try(node_group.min_size, var.min_node_count)
      node_repair_enabled        = try(node_group.node_repair_enabled, var.node_group_defaults.node_repair_enabled)
      release_version            = try(node_group.release_version, var.node_group_defaults.release_version)
      remote_access              = try(node_group.remote_access, var.node_group_defaults.remote_access)
      subnet_ids                 = try(node_group.subnet_ids, local.cluster_subnet_ids)
      taints                     = try(node_group.taints, var.node_group_defaults.taints)
      tags                       = merge(var.tags, try(node_group.tags, {}))
    }
  } : {}

  cluster_policy_arns = toset(concat(
    ["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"],
    var.cluster_mode == "auto" ? [
      "arn:aws:iam::aws:policy/AmazonEKSComputePolicy",
      "arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy",
      "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy",
      "arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy",
    ] : [],
    var.cluster_additional_policy_arns
  ))

  node_policy_arns = toset(concat(
    [
      "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
      "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
      "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly",
    ],
    var.node_additional_policy_arns
  ))

  access_policy_associations = length(var.access_entries) == 0 ? {} : merge([
    for entry_name, entry in var.access_entries : {
      for association_name, association in entry.policy_associations :
      "${entry_name}-${association_name}" => merge(association, {
        principal_arn = entry.principal_arn
      })
    }
  ]...)
}
