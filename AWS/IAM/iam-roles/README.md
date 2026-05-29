# AWS IAM Roles Terraform Module

Modulo reutilizable para crear roles IAM genericos. Soporta trust policy explicita o generacion de trust policy para IRSA.

## Que Crea

- `aws_iam_role`
- `aws_iam_role_policy` para inline policies
- `aws_iam_role_policy_attachment` para managed policies

## Rol IRSA

```hcl
module "iam_roles" {
  source = "./modules/iam-roles"

  roles = {
    external_secrets = {
      irsa = {
        oidc_provider_arn = module.eks.oidc_provider_arn
        oidc_issuer_url   = module.eks.cluster_oidc_issuer_url
        namespace         = "external-secrets"
        service_account   = "external-secrets"
      }

      inline_policies = {
        secrets_manager = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Action = [
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret"
              ]
              Resource = "*"
            }
          ]
        })
      }
    }
  }
}
```
