output "cluster_name" {
  description = "EKS cluster name."
  value       = aws_eks_cluster.this.name
}

output "cluster_arn" {
  description = "EKS cluster ARN."
  value       = aws_eks_cluster.this.arn
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded EKS cluster certificate authority data."
  value       = aws_eks_cluster.this.certificate_authority[0].data
  sensitive   = true
}

output "cluster_oidc_issuer_url" {
  description = "EKS cluster OIDC issuer URL."
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "cluster_security_group_id" {
  description = "Security group ID created by EKS for the cluster."
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN used by the EKS cluster."
  value       = local.cluster_role_arn
}

output "node_iam_role_arn" {
  description = "IAM role ARN used by EKS nodes."
  value       = local.node_role_arn
}

output "subnet_ids" {
  description = "Subnet IDs used by the EKS cluster."
  value       = local.cluster_subnet_ids
}

output "managed_node_groups" {
  description = "Managed node groups keyed by node group name."
  value = {
    for name, node_group in aws_eks_node_group.this : name => {
      arn    = node_group.arn
      id     = node_group.id
      status = node_group.status
    }
  }
}

output "cluster_addons" {
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
