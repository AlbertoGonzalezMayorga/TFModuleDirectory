# Azure Role Assignment Terraform Module

Modulo para crear asignaciones RBAC de Azure sobre scopes existentes.

## Que Crea

- `azurerm_role_assignment`

## Ejemplo

```hcl
module "role_assignment" {
  source = "./modules/Azure/IAM/role_assignment"

  role_assignments = {
    acr_pull = {
      scope                = module.acr.registries.platformdevacr.id
      role_definition_name = "AcrPull"
      principal_id         = module.aks.clusters["platform-dev"].kubelet_identity[0].object_id
    }
  }
}
```

## Inputs Principales

- `scope`: scope Azure del recurso, resource group, subscription, etc.
- `role_definition_name` o `role_definition_id`.
- `principal_id`: object ID del principal.

## Outputs

Consulta `outputs.tf` o el estado del modulo para IDs de asignaciones creadas.
