locals {
  roles = {
    for key, role in var.roles : key => merge(role, {
      inline_policies     = coalesce(role.inline_policies, {})
      managed_policy_arns = coalesce(role.managed_policy_arns, [])
      tags                = merge(var.tags, coalesce(role.tags, {}))
      assume_role_policy = role.irsa == null ? role.assume_role_policy : jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action = "sts:AssumeRoleWithWebIdentity"
            Effect = "Allow"
            Principal = {
              Federated = role.irsa.oidc_provider_arn
            }
            Condition = {
              StringEquals = {
                "${replace(role.irsa.oidc_issuer_url, "https://", "")}:aud" = role.irsa.audience
                "${replace(role.irsa.oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:${role.irsa.namespace}:${role.irsa.service_account}"
              }
            }
          }
        ]
      })
    })
  }

  inline_policies = length(local.roles) == 0 ? {} : merge([
    for role_key, role in local.roles : {
      for policy_name, policy in role.inline_policies :
      "${role_key}-${policy_name}" => {
        role_key = role_key
        name     = policy_name
        policy   = policy
      }
    }
  ]...)

  managed_policy_attachments = length(local.roles) == 0 ? {} : merge([
    for role_key, role in local.roles : {
      for policy_arn in role.managed_policy_arns :
      "${role_key}-${replace(replace(policy_arn, ":", "-"), "/", "-")}" => {
        role_key   = role_key
        policy_arn = policy_arn
      }
    }
  ]...)
}
