# AWS EKS Add-ons Terraform Module

Modulo reutilizable para instalar add-ons administrados de EKS y, cuando haga falta, crear los roles IAM previos para sus service accounts.

## Que Crea

- `aws_eks_addon`
- roles IAM para IRSA, si un add-on declara `irsa`
- policy attachments para esos roles IRSA
- asociaciones de Pod Identity, si se declaran

## Add-ons simples

```hcl
module "eks_addons" {
  source = "./modules/eks-addons"

  cluster_name = module.eks.cluster_name

  addons = {
    kube-proxy = {}
    vpc-cni    = {}
    coredns    = {}
  }
}
```

## Add-on con IRSA

```hcl
module "eks_addons" {
  source = "./modules/eks-addons"

  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_issuer_url   = module.eks.cluster_oidc_issuer_url

  addons = {
    aws-ebs-csi-driver = {
      irsa = {
        namespace       = "kube-system"
        service_account = "ebs-csi-controller-sa"
        policy_arns = [
          "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        ]
      }
    }
  }
}
```

## Add-on con role existente

```hcl
module "eks_addons" {
  source = "./modules/eks-addons"

  cluster_name = module.eks.cluster_name

  addons = {
    aws-ebs-csi-driver = {
      service_account_role_arn = "arn:aws:iam::123456789012:role/ebs-csi"
    }
  }
}
```

## Outputs principales

- `addons`
- `irsa_role_arns`
