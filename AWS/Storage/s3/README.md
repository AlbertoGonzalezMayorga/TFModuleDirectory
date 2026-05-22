# AWS S3 Terraform Module

Modulo generico para crear uno o varios buckets S3 con controles habituales de seguridad y operacion.

## Que Crea

- `aws_s3_bucket`
- `aws_s3_bucket_public_access_block`
- `aws_s3_bucket_versioning`, opcional por bucket
- `aws_s3_bucket_server_side_encryption_configuration`, opcional por bucket
- `aws_s3_bucket_logging`, opcional por bucket
- `aws_s3_bucket_lifecycle_configuration`, opcional por bucket

## Ejemplo Minimo

```hcl
module "s3" {
  source = "./modules/AWS/Storage/s3"

  buckets = {
    "platform-dev-artifacts" = {}
  }

  tags = {
    Environment = "dev"
    Project     = "platform"
  }
}
```

## Ejemplo Con Lifecycle Y Logging

```hcl
module "s3" {
  source = "./modules/AWS/Storage/s3"

  buckets = {
    "platform-dev-logs" = {
      force_destroy = false

      logging = {
        target_bucket = "platform-dev-access-logs"
        target_prefix = "s3/platform-dev-logs/"
      }

      lifecycle_rules = [
        {
          id              = "archive-logs"
          prefix          = "logs/"
          transition      = { days = 30, storage_class = "STANDARD_IA" }
          expiration_days = 365
        }
      ]
    }
  }
}
```

## Inputs Principales

- `buckets`: mapa de buckets a crear. La key es el nombre real del bucket.
- `force_destroy`: permite borrar buckets con objetos dentro.
- `public_access_block`: controles de bloqueo publico, activos por defecto.
- `versioning_status`: `Enabled`, `Suspended` o `Disabled`.
- `server_side_encryption`: `AES256` por defecto, con KMS opcional.
- `logging`: bucket/prefix de logs de acceso.
- `lifecycle_rules`: reglas de transicion, expiracion y multipart uploads.
- `tags`: tags comunes.

## Outputs

- `buckets`: mapa con `arn`, `bucket` e `id`.

## Notas

El modulo no crea bucket policies ni notificaciones. Usa el modulo `AWS/Storage/s3_policy` para asociar politicas de acceso.
