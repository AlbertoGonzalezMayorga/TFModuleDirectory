locals {
  oidc_provider_url = var.oidc_issuer_url == null ? null : replace(var.oidc_issuer_url, "https://", "")

  irsa_addons = {
    for name, addon in var.addons : name => addon
    if addon.irsa != null
  }

  irsa_policy_attachments = length(local.irsa_addons) == 0 ? {} : merge([
    for addon_name, addon in local.irsa_addons : {
      for policy_arn in addon.irsa.policy_arns :
      "${addon_name}-${replace(replace(policy_arn, ":", "-"), "/", "-")}" => {
        addon_name = addon_name
        policy_arn = policy_arn
        role_name  = aws_iam_role.irsa[addon_name].name
      }
    }
  ]...)
}
