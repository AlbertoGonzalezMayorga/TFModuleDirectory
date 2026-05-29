output "addons" {
  description = "EKS add-ons keyed by add-on name."
  value = {
    for name, addon in aws_eks_addon.this : name => {
      addon_name    = addon.addon_name
      addon_version = addon.addon_version
      arn           = addon.arn
      id            = addon.id
    }
  }
}

output "irsa_role_arns" {
  description = "IRSA role ARNs keyed by add-on name."
  value = {
    for name, role in aws_iam_role.irsa : name => role.arn
  }
}
