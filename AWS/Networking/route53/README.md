# AWS Route53 Terraform Module

Modulo para crear o consultar hosted zones de Route53, crear records y configurar delegaciones NS.

## Que Crea

- `aws_route53_zone`, para zonas con `create = true`
- `data.aws_route53_zone`, para zonas existentes
- `aws_route53_record`, para records normales, alias y routing policies
- `aws_route53_record` tipo `NS`, para delegaciones

## Ejemplo Zona Y Record

```hcl
module "route53" {
  source = "./modules/AWS/Networking/route53"

  zones = {
    public = {
      name    = "example.com"
      private = false
    }
  }

  records = [
    {
      zone_key = "public"
      name     = "www"
      type     = "CNAME"
      ttl      = 300
      records  = ["example.com"]
    }
  ]
}
```

## Alias Record

```hcl
records = [
  {
    zone_key = "public"
    name     = "@"
    type     = "A"
    alias = {
      name    = module.alb.load_balancer.dns_name
      zone_id = module.alb.load_balancer.zone_id
    }
  }
]
```

## Zona Privada

```hcl
zones = {
  internal = {
    name    = "internal.example.com"
    private = true
    vpcs = [
      {
        vpc_id     = "vpc-0123456789abcdef0"
        vpc_region = "eu-west-1"
      }
    ]
  }
}
```

## Inputs Principales

- `zones`: mapa de hosted zones a crear o buscar.
- `records`: lista de records.
- `delegations`: delegaciones NS desde una zona padre.
- `tags`: tags comunes.

## Outputs

Consulta `outputs.tf` para IDs de zonas, name servers y records generados.
