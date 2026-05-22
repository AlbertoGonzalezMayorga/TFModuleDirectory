# AWS ECR Repository Terraform Module

Modulo reutilizable para crear repositorios de Amazon Elastic Container Registry. Cada ECR repository es el contenedor logico donde se almacenan imagenes Docker/OCI y artifacts.

## Que Crea

- `aws_ecr_repository`
- `aws_ecr_lifecycle_policy`, opcional por repositorio
- `aws_ecr_repository_policy`, opcional por repositorio

## Crear Un Repositorio

```hcl
module "ecr" {
  source = "./modules/AWS/Containers/ecr"

  repositories = {
    "platform/api" = {}
  }

  tags = {
    Environment = "dev"
    Project     = "platform"
  }
}
```

## Crear Multiples Repositorios

```hcl
module "ecr" {
  source = "./modules/AWS/Containers/ecr"

  image_tag_mutability = "IMMUTABLE"
  scan_on_push         = true

  repositories = {
    "platform/api" = {
      lifecycle_policy = jsonencode({
        rules = [
          {
            rulePriority = 1
            description  = "Keep the last 20 images"
            selection = {
              tagStatus   = "any"
              countType   = "imageCountMoreThan"
              countNumber = 20
            }
            action = {
              type = "expire"
            }
          }
        ]
      })
    }

    "platform/worker" = {
      force_delete         = true
      image_tag_mutability = "MUTABLE"
      tags = {
        Component = "worker"
      }
    }
  }
}
```

## Cifrado Con KMS

```hcl
module "ecr" {
  source = "./modules/AWS/Containers/ecr"

  encryption_type    = "KMS"
  encryption_kms_key = "arn:aws:kms:eu-west-1:123456789012:key/00000000-0000-0000-0000-000000000000"

  repositories = {
    "secure/app" = {}
  }
}
```

## Inputs Principales

- `repositories`: mapa de repositorios. La key es el nombre del repo.
- `image_tag_mutability`: `MUTABLE`, `IMMUTABLE` o modos con exclusion.
- `tag_mutability_filters`: filtros para modos `*_WITH_EXCLUSION`.
- `scan_on_push`: escaneo basico al hacer push.
- `encryption_type`: `AES256` o `KMS`.
- `lifecycle_policy`: policy JSON por defecto.
- `repository_policy`: policy JSON por repositorio.
- `tags`: tags comunes.

## Outputs

- `repositories`: mapa con ARN, ID, nombre, registry ID, URL y tags de repositorios creados.
