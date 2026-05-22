# AWS EKS Terraform Module

Modulo reutilizable para crear clusters de Amazon EKS con Auto Mode o managed node groups clasicos. Puede crear roles IAM, crear subnets simples si se solicita, instalar add-ons administrados y configurar access entries.

## Ejemplo minimo con subnets existentes

```hcl
module "eks" {
  source = "./modules/eks"

  cluster_name = "platform-dev"
  subnet_ids   = ["subnet-0123456789abcdef0", "subnet-0fedcba9876543210"]

  tags = {
    Environment = "dev"
    Project     = "platform"
  }
}
```

## EKS Auto Mode

```hcl
module "eks" {
  source = "./modules/eks"

  cluster_name = "platform-auto"
  cluster_mode = "auto"
  subnet_ids   = ["subnet-0123456789abcdef0", "subnet-0fedcba9876543210"]

  auto_node_pools = ["system", "general-purpose"]
}
```

## Managed node groups clasicos

```hcl
module "eks" {
  source = "./modules/eks"

  cluster_name = "platform-classic"
  cluster_mode = "classic"
  subnet_ids   = ["subnet-0123456789abcdef0", "subnet-0fedcba9876543210"]

  managed_node_groups = {
    system = {
      desired_size   = 2
      min_size       = 2
      max_size       = 4
      instance_types = ["t3.medium"]
      labels = {
        workload = "system"
      }
    }

    apps = {
      desired_size   = 3
      min_size       = 2
      max_size       = 8
      capacity_type  = "SPOT"
      instance_types = ["t3.large", "t3a.large"]
    }
  }
}
```

## Crear subnets desde el modulo

```hcl
module "eks" {
  source = "./modules/eks"

  cluster_name   = "platform-networked"
  create_subnets = true
  vpc_id         = "vpc-0123456789abcdef0"
  vpc_cidr       = "10.0.0.0/16"
  subnet_count   = 3
}
```

## Add-ons

```hcl
module "eks" {
  source = "./modules/eks"

  cluster_name = "platform-addons"
  subnet_ids   = ["subnet-0123456789abcdef0", "subnet-0fedcba9876543210"]

  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts_on_update = "OVERWRITE"
    }
  }
}
```

## Access entries

```hcl
module "eks" {
  source = "./modules/eks"

  cluster_name = "platform-access"
  subnet_ids   = ["subnet-0123456789abcdef0", "subnet-0fedcba9876543210"]

  access_entries = {
    admins = {
      principal_arn = "arn:aws:iam::123456789012:role/Admin"
      policy_associations = {
        cluster_admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
}
```

## Roles IAM existentes

```hcl
module "eks" {
  source = "./modules/eks"

  cluster_name = "platform-existing-iam"
  subnet_ids   = ["subnet-0123456789abcdef0", "subnet-0fedcba9876543210"]

  create_cluster_iam_role = false
  cluster_iam_role_arn    = "arn:aws:iam::123456789012:role/existing-eks-cluster-role"

  create_node_iam_role = false
  node_iam_role_arn    = "arn:aws:iam::123456789012:role/existing-eks-node-role"
}
```

## Outputs principales

- `cluster_name`, `cluster_arn`, `cluster_endpoint`
- `cluster_certificate_authority_data`
- `cluster_oidc_issuer_url`
- `cluster_security_group_id`
- `cluster_iam_role_arn`, `node_iam_role_arn`
- `subnet_ids`
- `managed_node_groups`
- `cluster_addons`
