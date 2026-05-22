# AWS VPC Terraform Module

Modulo para crear una VPC nueva o referenciar una existente y, opcionalmente, habilitar VPC Flow Logs hacia CloudWatch Logs o S3.

## Ejemplo

```hcl
module "vpc" {
  source = "./modules/AWS/Networking/vpc"

  vpc_cidr = "10.0.0.0/16"

  create_flow_log      = true
  log_destination_type = "cloud-watch-logs"

  tags = {
    Environment = "dev"
    Project     = "platform"
  }
}
```

## Outputs

Consulta `outputs.tf` para los IDs/ARNs expuestos por el modulo.
