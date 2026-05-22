# AWS CloudFront Terraform Module

Modulo generico para crear una distribucion CloudFront con origins, cache behaviors, certificado, logging y Origin Access Control opcional.

## Que Crea

- `aws_cloudfront_distribution`
- `aws_cloudfront_origin_access_control`, opcional por origin

## Ejemplo Con Origin S3 Y OAC

```hcl
module "cloudfront" {
  source = "./modules/AWS/Networking/cloudfront"

  origins = {
    s3 = {
      domain_name                  = "platform-dev-site.s3.eu-west-1.amazonaws.com"
      create_origin_access_control = true
      origin_access_control = {
        name = "platform-dev-site-oac"
      }
    }
  }

  default_cache_behavior = {
    target_origin_id = "s3"
    cache_policy_id  = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }
}
```

## Ejemplo Con Custom Origin

```hcl
origins = {
  app = {
    domain_name = "internal-app.example.com"
    custom_origin_config = {
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
}

default_cache_behavior = {
  target_origin_id = "app"
}
```

## Inputs Principales

- `origins`: mapa de origins. La key es el `origin_id`.
- `default_cache_behavior`: comportamiento por defecto.
- `ordered_cache_behaviors`: behaviors adicionales por `path_pattern`.
- `viewer_certificate`: ACM certificate opcional; si no se pasa, usa certificado default de CloudFront.
- `logging_config`: bucket, prefix y cookies.
- `geo_restriction`: restricciones geograficas.
- `web_acl_id`: WAF ACL opcional.

## Outputs

- `distribution`: `arn`, `domain_name`, `hosted_zone_id`, `id`.

## Notas

CloudFront requiere que certificados ACM para aliases custom esten en `us-east-1`.
