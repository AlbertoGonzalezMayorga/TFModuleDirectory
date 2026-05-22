# AWS ECR Repository Terraform Module

Modulo reutilizable para crear repositorios de Amazon Elastic Container Registry. Cada ECR repository es el contenedor logico donde se almacenan imagenes Docker/OCI y artifacts.

## Crear un repositorio

```hcl
module "ecr" {
  source = "./modules/ecr"

  repositories = {
    "platform/api" = {}
  }

  tags = {
    Environment = "dev"
    Project     = "platform"
  }
}
```

## Crear multiples repositorios

```hcl
module "ecr" {
  source = "./modules/ecr"

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

  tags = {
    Environment = "prod"
    Project     = "platform"
  }
}
```

## Cifrado con KMS

```hcl
module "ecr" {
  source = "./modules/ecr"

  encryption_type    = "KMS"
  encryption_kms_key = "arn:aws:kms:eu-west-1:123456789012:key/00000000-0000-0000-0000-000000000000"

  repositories = {
    "secure/app" = {}
  }
}
```

## Outputs principales

- `repositories`: mapa con ARN, ID, nombre, registry ID, URL y tags de repositorios creados.
