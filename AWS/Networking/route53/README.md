# AWS Route53 Terraform Module

Modulo para crear o consultar hosted zones de Route53, crear records y configurar delegaciones NS.

## Ejemplo

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
