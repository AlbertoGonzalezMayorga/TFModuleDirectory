resource "aws_iam_role" "irsa" {
  for_each = local.irsa_addons

  name                 = each.value.irsa.role_name
  name_prefix          = each.value.irsa.role_name == null ? coalesce(each.value.irsa.role_name_prefix, substr("${var.cluster_name}-${each.key}-", 0, 38)) : null
  permissions_boundary = each.value.irsa.permissions_boundary

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${local.oidc_provider_url}:aud" = "sts.amazonaws.com"
            "${local.oidc_provider_url}:sub" = "system:serviceaccount:${each.value.irsa.namespace}:${each.value.irsa.service_account}"
          }
        }
      }
    ]
  })

  tags = merge(var.tags, each.value.irsa.tags)

  lifecycle {
    precondition {
      condition     = var.oidc_provider_arn != null && var.oidc_issuer_url != null
      error_message = "oidc_provider_arn and oidc_issuer_url are required when any add-on declares irsa."
    }
  }
}

resource "aws_iam_role_policy_attachment" "irsa" {
  for_each = local.irsa_policy_attachments

  policy_arn = each.value.policy_arn
  role       = each.value.role_name
}

resource "aws_eks_addon" "this" {
  for_each = var.addons

  addon_name                  = each.key
  addon_version               = each.value.addon_version
  cluster_name                = var.cluster_name
  configuration_values        = each.value.configuration_values
  preserve                    = each.value.preserve
  resolve_conflicts_on_create = each.value.resolve_conflicts_on_create
  resolve_conflicts_on_update = each.value.resolve_conflicts_on_update
  service_account_role_arn    = each.value.irsa == null ? each.value.service_account_role_arn : aws_iam_role.irsa[each.key].arn
  tags                        = merge(var.tags, each.value.tags)

  dynamic "pod_identity_association" {
    for_each = each.value.pod_identity_associations

    content {
      role_arn        = pod_identity_association.value.role_arn
      service_account = pod_identity_association.value.service_account
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.irsa,
  ]
}
