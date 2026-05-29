data "aws_availability_zones" "available" {
  state         = "available"
  exclude_names = ["us-east-1e"] # EKS does not support creating control plane instances in us-east-1e
}

resource "aws_subnet" "this" {
  count = var.create_subnets ? var.subnet_count : 0

  availability_zone       = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
  cidr_block              = local.generated_subnet_cidrs[count.index]
  map_public_ip_on_launch = var.map_public_ip_on_launch
  vpc_id                  = var.vpc_id

  tags = merge(
    var.tags,
    var.subnet_tags,
    {
      Name = "${var.cluster_name}-${var.subnet_name_suffix}-${count.index + 1}"
    }
  )

  lifecycle {
    precondition {
      condition     = local.generated_subnet_prefix <= 28
      error_message = "Cannot create ${var.subnet_count} valid AWS IPv4 subnets from ${var.vpc_cidr}. The generated subnet prefix would be /${local.generated_subnet_prefix}, but AWS only accepts IPv4 subnets up to /28."
    }
  }
}

resource "aws_iam_role" "cluster" {
  count = var.create_cluster_iam_role ? 1 : 0

  name                 = var.cluster_iam_role_name
  name_prefix          = var.cluster_iam_role_name == null ? var.cluster_iam_role_name_prefix : null
  description          = "IAM role used by the ${var.cluster_name} EKS cluster."
  permissions_boundary = var.cluster_iam_role_permissions_boundary

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "cluster" {
  for_each = var.create_cluster_iam_role ? local.cluster_policy_arns : toset([])

  policy_arn = each.value
  role       = aws_iam_role.cluster[0].name
}

resource "aws_iam_role" "node" {
  count = var.create_node_iam_role ? 1 : 0

  name                 = var.node_iam_role_name
  name_prefix          = var.node_iam_role_name == null ? var.node_iam_role_name_prefix : null
  description          = "IAM role used by ${var.cluster_name} EKS nodes."
  permissions_boundary = var.node_iam_role_permissions_boundary

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRole"]
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "node" {
  for_each = var.create_node_iam_role ? local.node_policy_arns : toset([])

  policy_arn = each.value
  role       = aws_iam_role.node[0].name
}

resource "aws_eks_cluster" "this" {
  name                          = var.cluster_name
  role_arn                      = local.cluster_role_arn
  version                       = var.kubernetes_version
  enabled_cluster_log_types     = var.enabled_cluster_log_types
  bootstrap_self_managed_addons = var.cluster_mode == "auto" ? false : var.bootstrap_self_managed_addons
  deletion_protection           = var.deletion_protection

  access_config {
    authentication_mode                         = var.authentication_mode
    bootstrap_cluster_creator_admin_permissions = var.bootstrap_cluster_creator_admin_permissions
  }

  dynamic "compute_config" {
    for_each = var.cluster_mode == "auto" ? [1] : []

    content {
      enabled       = var.auto_compute_config_enabled
      node_pools    = var.auto_node_pools
      node_role_arn = local.node_role_arn
    }
  }

  dynamic "encryption_config" {
    for_each = var.encryption_config == null ? [] : [var.encryption_config]

    content {
      resources = encryption_config.value.resources

      provider {
        key_arn = encryption_config.value.kms_key_arn
      }
    }
  }

  kubernetes_network_config {
    ip_family         = var.ip_family
    service_ipv4_cidr = var.service_ipv4_cidr
    service_ipv6_cidr = var.service_ipv6_cidr

    dynamic "elastic_load_balancing" {
      for_each = var.cluster_mode == "auto" ? [1] : []

      content {
        enabled = var.auto_elastic_load_balancing_enabled
      }
    }
  }

  dynamic "storage_config" {
    for_each = var.cluster_mode == "auto" ? [1] : []

    content {
      block_storage {
        enabled = var.auto_block_storage_enabled
      }
    }
  }

  dynamic "upgrade_policy" {
    for_each = var.upgrade_policy == null ? [] : [var.upgrade_policy]

    content {
      support_type = upgrade_policy.value.support_type
    }
  }

  vpc_config {
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
    security_group_ids      = var.cluster_security_group_ids
    subnet_ids              = local.cluster_subnet_ids
  }

  tags = var.tags

  depends_on = [
    aws_iam_role_policy_attachment.cluster,
    aws_iam_role_policy_attachment.node,
  ]
}

resource "aws_iam_openid_connect_provider" "this" {
  count = var.create_oidc_provider ? 1 : 0

  client_id_list = ["sts.amazonaws.com"]
  url            = local.oidc_issuer_url

  tags = var.tags
}

resource "aws_eks_node_group" "this" {
  for_each = local.managed_node_groups

  ami_type             = each.value.launch_template == null ? each.value.ami_type : null
  capacity_type        = each.value.capacity_type
  cluster_name         = aws_eks_cluster.this.name
  disk_size            = each.value.launch_template == null ? each.value.disk_size : null
  force_update_version = each.value.force_update_version
  instance_types       = each.value.launch_template == null ? each.value.instance_types : null
  labels               = each.value.labels
  node_group_name      = each.key
  node_role_arn        = local.node_role_arn
  release_version      = each.value.release_version
  subnet_ids           = each.value.subnet_ids
  tags                 = each.value.tags
  version              = each.value.kubernetes_version

  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }

  dynamic "launch_template" {
    for_each = each.value.launch_template == null ? [] : [each.value.launch_template]

    content {
      id      = launch_template.value.id
      name    = launch_template.value.name
      version = launch_template.value.version
    }
  }

  dynamic "node_repair_config" {
    for_each = each.value.node_repair_enabled == null ? [] : [each.value.node_repair_enabled]

    content {
      enabled = node_repair_config.value
    }
  }

  dynamic "remote_access" {
    for_each = each.value.remote_access == null ? [] : [each.value.remote_access]

    content {
      ec2_ssh_key               = remote_access.value.ec2_ssh_key
      source_security_group_ids = remote_access.value.source_security_group_ids
    }
  }

  dynamic "taint" {
    for_each = each.value.taints

    content {
      effect = taint.value.effect
      key    = taint.value.key
      value  = taint.value.value
    }
  }

  update_config {
    max_unavailable            = each.value.max_unavailable_percentage == null ? each.value.max_unavailable : null
    max_unavailable_percentage = each.value.max_unavailable_percentage
  }

  depends_on = [
    aws_iam_role_policy_attachment.node,
  ]

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}

resource "aws_eks_access_entry" "this" {
  for_each = var.access_entries

  cluster_name      = aws_eks_cluster.this.name
  kubernetes_groups = each.value.kubernetes_groups
  principal_arn     = each.value.principal_arn
  tags              = merge(var.tags, each.value.tags)
  type              = each.value.type
  user_name         = each.value.user_name
}

resource "aws_eks_access_policy_association" "this" {
  for_each = local.access_policy_associations

  cluster_name  = aws_eks_cluster.this.name
  policy_arn    = each.value.policy_arn
  principal_arn = each.value.principal_arn

  access_scope {
    namespaces = each.value.access_scope.namespaces
    type       = each.value.access_scope.type
  }

  depends_on = [
    aws_eks_access_entry.this,
  ]
}
