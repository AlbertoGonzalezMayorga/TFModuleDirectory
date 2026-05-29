# Azure Managed Identity

Modulo reutilizable para crear identidades administradas user-assigned en Azure, credenciales federadas y asignaciones RBAC asociadas. Es la contraparte habitual en Azure para patrones que en AWS se resuelven con IAM Roles, como workloads con identidad propia o integraciones con Kubernetes mediante OIDC.

## Uso

```hcl
module "managed_identity" {
  source = "./Azure/IAM/managed_identity"

  tags = {
    environment = "prod"
  }

  identities = {
    external_dns = {
      resource_group_name = "rg-platform"
      location            = "westeurope"

      federated_credentials = {
        aks = {
          issuer  = module.aks.clusters.platform.oidc_issuer_url
          subject = "system:serviceaccount:external-dns:external-dns"
        }
      }

      role_assignments = {
        dns_zone = {
          scope                = azurerm_dns_zone.public.id
          role_definition_name = "DNS Zone Contributor"
        }
      }
    }
  }
}
```

## Entradas principales

- `identities`: mapa de identidades a crear. La clave se usa como nombre si no se define `name`.
- `federated_credentials`: credenciales OIDC para workloads como AKS Workload Identity.
- `role_assignments`: permisos RBAC asignados al principal de la identidad.
- `tags`: etiquetas comunes para los recursos soportados.

## Salidas

- `identities`: IDs, client IDs, principal IDs y metadatos de cada identidad.
- `client_ids`: client IDs por identidad.
- `principal_ids`: principal IDs por identidad.
- `role_assignments`: IDs de asignaciones RBAC creadas.
