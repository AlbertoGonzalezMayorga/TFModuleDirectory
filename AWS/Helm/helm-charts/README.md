# Helm Charts Terraform Module

Modulo reutilizable para instalar charts Helm y aplicar manifiestos Kubernetes adicionales.

## Que Crea

- `helm_release`
- `kubernetes_manifest` opcional para manifiestos extra

## External Secrets y Stakater Reloader

```hcl
module "helm_charts" {
  source = "./modules/helm-charts"

  releases = {
    external_secrets = {
      name             = "external-secrets"
      repository       = "https://charts.external-secrets.io"
      chart            = "external-secrets"
      chart_version    = "2.4.1"
      namespace        = "external-secrets"
      create_namespace = true
      values = {
        installCRDs = true
        serviceAccount = {
          create = true
          name   = "external-secrets"

          annotations = {
            "eks.amazonaws.com/role-arn" = module.iam_roles.role_arns["external_secrets"]
          }
        }
      }
    }
  }

  extra_manifests = {
    aws_secrets_manager = {
      apiVersion = "external-secrets.io/v1"
      kind       = "ClusterSecretStore"
      metadata = {
        name = "aws-secrets-manager"
      }
      spec = {
        provider = {
          aws = {
            service = "SecretsManager"
            region  = "eu-west-1"
            auth = {
              jwt = {
                serviceAccountRef = {
                  name      = "external-secrets"
                  namespace = "external-secrets"
                }
              }
            }
          }
        }
      }
    }
  }
}

module "stakater_reloader" {
  source = "./modules/helm-charts"

  releases = {
    stakater_reloader = {
      name             = "stakater-reloader"
      repository       = "https://stakater.github.io/stakater-charts"
      chart            = "reloader"
      namespace        = "stakater-reloader"
      create_namespace = true
    }
  }
}
```
