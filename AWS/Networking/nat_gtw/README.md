# AWS NAT Gateway Terraform Module

Modulo generico para crear NAT Gateways publicos en subnets existentes. Opcionalmente puede crear rutas `0.0.0.0/0` u otro CIDR en route tables existentes.

## Que Crea

- `aws_eip`
- `aws_nat_gateway`
- `aws_route`, opcional por route table

## Ejemplo

```hcl
module "nat" {
  source = "./modules/AWS/Networking/nat_gtw"

  nat_gateways = {
    euw1a = {
      subnet_id       = "subnet-public-a"
      route_table_ids = ["rtb-private-a"]
    }

    euw1b = {
      subnet_id       = "subnet-public-b"
      route_table_ids = ["rtb-private-b"]
    }
  }

  tags = {
    Environment = "dev"
  }
}
```

## Inputs Principales

- `nat_gateways`: mapa de NAT Gateways. La key es un nombre amigable.
- `subnet_id`: subnet publica donde vive el NAT.
- `route_table_ids`: tablas de rutas privadas que apuntaran al NAT.
- `destination_cidr_block`: por defecto `0.0.0.0/0`.

## Outputs

- `nat_gateways`: `id`, `allocation_id` y `public_ip`.

## Notas

El modulo no crea Internet Gateway ni subnets. Eso debe venir de un modulo de red/VPC.
