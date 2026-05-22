resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  scope                            = each.value.scope
  principal_id                     = each.value.principal_id
  role_definition_name             = try(each.value.role_definition_name, null)
  role_definition_id               = try(each.value.role_definition_id, null)
  principal_type                   = try(each.value.principal_type, null)
  skip_service_principal_aad_check = try(each.value.skip_service_principal_aad_check, false)
}