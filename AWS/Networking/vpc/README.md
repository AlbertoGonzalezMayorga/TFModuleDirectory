# AWS VPC Terraform Module

Modulo reutilizable para componer redes AWS de forma plug and play. Puede crear una VPC nueva o trabajar sobre una existente, y genera subnets publicas, privadas e aisladas con las rutas necesarias.

## Que Crea

- `aws_vpc`, si `create_vpc = true`
- `aws_subnet.public`
- `aws_subnet.private`
- `aws_subnet.isolated`
- `aws_internet_gateway`, si hay subnets publicas
- `aws_nat_gateway`, si `enable_nat_gateway = true`
- route tables y asociaciones por tipo de subnet
- VPC Flow Logs opcionales

## Red EKS-ready

```hcl
module "vpc" {
  source = "./modules/vpc"

  name     = "platform-dev"
  vpc_cidr = "10.0.0.0/16"

  public_subnet_count  = 3
  private_subnet_count = 3

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/cluster/platform-dev" = "shared"
    "kubernetes.io/role/elb"             = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/platform-dev" = "shared"
    "kubernetes.io/role/internal-elb"    = "1"
  }
}

module "eks" {
  source = "./modules/eks"

  cluster_name = "platform-dev"
  subnet_ids   = module.vpc.private_subnet_ids
}
```

## Alta disponibilidad de NAT

```hcl
module "vpc" {
  source = "./modules/vpc"

  name                 = "platform-prod"
  vpc_cidr             = "10.20.0.0/16"
  public_subnet_count  = 3
  private_subnet_count = 3

  enable_nat_gateway = true
  single_nat_gateway = false
}
```

## Subnets con CIDRs explicitos

```hcl
module "vpc" {
  source = "./modules/vpc"

  name     = "custom-network"
  vpc_cidr = "10.30.0.0/16"

  public_subnet_cidrs = [
    "10.30.0.0/24",
    "10.30.1.0/24",
  ]

  private_subnet_cidrs = [
    "10.30.10.0/24",
    "10.30.11.0/24",
  ]

  isolated_subnet_cidrs = [
    "10.30.20.0/24",
    "10.30.21.0/24",
  ]
}
```

## Solo red aislada

```hcl
module "vpc" {
  source = "./modules/vpc"

  name                  = "isolated"
  vpc_cidr              = "10.40.0.0/16"
  public_subnet_count   = 0
  private_subnet_count  = 0
  isolated_subnet_count = 3
}
```

## Outputs principales

- `vpc_id`, `vpc_cidr_block`
- `availability_zones`
- `public_subnet_ids`, `private_subnet_ids`, `isolated_subnet_ids`
- `public_route_table_ids`, `private_route_table_ids`, `isolated_route_table_ids`
- `internet_gateway_id`
- `nat_gateway_ids`, `nat_gateway_public_ips`

## Notas

- Para EKS, normalmente usa `private_subnet_ids` para los node groups y deja las publicas para load balancers/NAT.
- Los tags de discovery para EKS/Kubernetes se pasan con `public_subnet_tags` y `private_subnet_tags`; el modulo VPC no tiene conocimiento especifico de EKS.
- `single_nat_gateway = true` reduce coste; `false` mejora tolerancia a fallo por AZ.
