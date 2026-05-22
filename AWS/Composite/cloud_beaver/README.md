# Terraform module: CloudBeaver (DBeaver Web) on a disposable EC2 instance

This module deploys **CloudBeaver** (DBeaver web UI) on a small **EC2** instance running Docker.
It is designed for **plug-in / plug-out** database admin tasks:
- `terraform apply` when needed
- connect
- `terraform destroy` when finished (removes the instance and the DB SG exception)

## What it creates
- 1x EC2 instance (Amazon Linux 2023) with Docker + CloudBeaver container
- 1x Security Group for CloudBeaver
- (Optional) IAM role/instance profile for SSM Session Manager
- (Optional) Elastic IP
- (Optional) Ingress rules on your DB security group(s) to allow access from CloudBeaver SG

## Key inputs
- `vpc_id`, `subnet_id`: where the EC2 instance runs (typically a **public subnet** for direct internet access)
- `allowed_ingress_cidrs`: restrict access to your IP/VPN CIDRs (required unless `enable_ssm_only=true`)
- `db_access_rules`: list of DB SGs + ports to open **from CloudBeaver SG**

> Note: SG-to-SG rules require the DB security group to be in the **same VPC** as CloudBeaver.

## Examples

### Direct browser access (public IP)
```hcl
module "cloudbeaver" {
  source = "./tf-cloudbeaver-ec2"

  name      = "cloudbeaver-admin"
  vpc_id    = var.vpc_id
  subnet_id = var.public_subnet_id

  associate_public_ip_address = true

  allowed_ingress_cidrs = ["203.0.113.10/32"]

  db_access_rules = [
    { security_group_id = var.db_sg_id, port = 5432, description = "Postgres from CloudBeaver" }
  ]

  ttl_minutes = 240
}
```

### No inbound exposure (SSM port forwarding)
```hcl
module "cloudbeaver" {
  source = "./tf-cloudbeaver-ec2"

  name      = "cloudbeaver-admin"
  vpc_id    = var.vpc_id
  subnet_id = var.private_subnet_id

  associate_public_ip_address = false
  enable_ssm_only             = true
  enable_ssm                  = true

  # Ensure the subnet has outbound internet (NAT) so Docker can pull the image.
  # Or use a public subnet and keep enable_ssm_only=true if you prefer.
}
```

Then run the output `ssm_port_forward_command`, and open:
`http://localhost:8978`

## Operational guidance
- Keep `allowed_ingress_cidrs` tight (office/VPN only).
- Prefer `terraform destroy` to fully remove recurring costs.
- Consider `ttl_minutes` to auto-terminate if you forget to destroy.

