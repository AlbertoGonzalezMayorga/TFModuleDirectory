# AWS EKS Terraform Module

Modulo reutilizable para crear clusters de Amazon EKS con Auto Mode o managed node groups clasicos. Puede crear roles IAM, crear subnets simples si se solicita, instalar add-ons administrados y configurar access entries.

## Que Crea

- `aws_eks_cluster`
- `aws_eks_node_group`, cuando `cluster_mode = "classic"`
- `aws_eks_addon`, si se declaran add-ons
- `aws_eks_access_entry` y `aws_eks_access_policy_association`, si se declaran access entries
- roles IAM de cluster y nodos, si `create_*_iam_role = true`
- subnets simples, si `create_subnets = true`

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

## Inputs principales

- `cluster_name`: nombre del cluster.
- `cluster_mode`: `auto` o `classic`.
- `subnet_ids`: subnets existentes recomendadas.
- `create_subnets`, `vpc_id`, `vpc_cidr`: creacion simple de subnets desde el modulo.
- `kubernetes_version`: version concreta, o `null` para default de AWS.
- `authentication_mode`: `API`, `CONFIG_MAP` o `API_AND_CONFIG_MAP`.
- `managed_node_groups`: node groups configurables para modo classic.
- `cluster_addons`: add-ons administrados por EKS.
- `access_entries`: acceso IAM moderno al cluster.

## Notas

Para produccion, normalmente conviene pasar `subnet_ids` desde un modulo VPC dedicado. La creacion de subnets incluida es intencionadamente simple.
