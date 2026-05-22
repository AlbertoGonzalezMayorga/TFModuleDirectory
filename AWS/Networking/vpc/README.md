# AWS VPC Terraform Module

Modulo para crear una VPC nueva o referenciar una existente y, opcionalmente, configurar VPC Flow Logs hacia CloudWatch Logs o S3.

## Que Crea

- `aws_vpc`, si `create_vpc = true`
- `aws_flow_log`, si `create_flow_log = true`
- `aws_cloudwatch_log_group`, si el destino es CloudWatch Logs

## Ejemplo VPC Nueva

```hcl
module "vpc" {
  source = "./modules/AWS/Networking/vpc"

  create_vpc = true
  vpc_cidr   = "10.0.0.0/16"

  create_flow_log      = true
  log_destination_type = "cloud-watch-logs"

  region = "eu-west-1"
  tags = {
    Environment = "dev"
  }
}
```

## Ejemplo VPC Existente

```hcl
module "vpc" {
  source = "./modules/AWS/Networking/vpc"

  create_vpc = false
  vpc_id     = "vpc-0123456789abcdef0"
  vpc_cidr   = "10.0.0.0/16"
  region     = "eu-west-1"
}
```

## Flow Logs A S3

```hcl
create_flow_log      = true
log_destination_type = "s3"
logs_bucket_arn      = "arn:aws:s3:::platform-dev-vpc-flow-logs"
```

## Inputs Principales

- `create_vpc`: crea VPC o usa una existente.
- `vpc_id`: requerido cuando `create_vpc = false`.
- `vpc_cidr`: CIDR de la VPC.
- `create_flow_log`: activa VPC Flow Logs.
- `log_destination_type`: `cloud-watch-logs` o `s3`.
- `logs_bucket_arn`: requerido para destino S3.
- `traffic_type`: `ACCEPT`, `REJECT` o `ALL`.

## Outputs

Consulta `outputs.tf` para los IDs/ARNs expuestos por el modulo.
