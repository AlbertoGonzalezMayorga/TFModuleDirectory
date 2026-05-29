# Azure RBAC Role Assignment Terraform Module

Modulo para crear asignaciones RBAC de Azure sobre scopes existentes. Este modulo no crea identidades: recibe un `principal_id` existente y le asigna roles sobre subscriptions, resource groups o recursos concretos.

## Que Crea

- `azurerm_role_assignment`

## Cuando Usarlo

Usa este modulo cuando el principal ya existe:

- user-assigned managed identities creadas por otro modulo
- system-assigned identities de App Service, AKS, Functions, etc.
- service principals
- grupos o usuarios de Entra ID

Para crear managed identities user-assigned con credenciales federadas, usa `Azure/IAM/managed_identity`.

## Ejemplo

```hcl
module "acr_pull_assignment" {
  source = "./modules/Azure/IAM/role_assignment"

  role_assignments = {
    acr_pull = {
      scope                = module.acr.registries.platformdevacr.id
      role_definition_name = "AcrPull"
      principal_id         = module.aks.clusters["platform-dev"].kubelet_identity[0].object_id
      principal_type       = "ServicePrincipal"
    }
  }
}
```

## Ejemplo Con Multiples Asignaciones

```hcl
module "role_assignments" {
  source = "./modules/Azure/IAM/role_assignment"

  role_assignments = {
    logs_reader = {
      scope                = module.log_analytics_workspace.id
      role_definition_name = "Log Analytics Reader"
      principal_id         = module.managed_identity.principal_ids["platform_api"]
      principal_type       = "ServicePrincipal"
    }

    storage_reader = {
      scope                = module.storage.storage_accounts.platform.id
      role_definition_name = "Storage Blob Data Reader"
      principal_id         = module.managed_identity.principal_ids["platform_api"]
      principal_type       = "ServicePrincipal"
    }
  }
}
```

## Inputs Principales

- `role_assignments`: mapa de asignaciones RBAC.
- `scope`: scope Azure del recurso, resource group o subscription.
- `principal_id`: object ID del principal.
- `role_definition_name` o `role_definition_id`: exactamente uno debe estar definido.
- `principal_type`: `User`, `Group` o `ServicePrincipal`.
- `skip_service_principal_aad_check`: util para service principals recien creados.

## Outputs

- `role_assignments`: metadatos de asignaciones RBAC por clave logica.
- `role_assignment_ids`: IDs de asignaciones RBAC por clave logica.
