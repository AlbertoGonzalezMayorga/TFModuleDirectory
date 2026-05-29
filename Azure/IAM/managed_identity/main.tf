resource "azurerm_user_assigned_identity" "this" {
  for_each = local.identities

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location

  tags = each.value.tags
}

resource "azurerm_federated_identity_credential" "this" {
  for_each = local.federated_credentials

  name                = each.value.name
  resource_group_name = azurerm_user_assigned_identity.this[each.value.identity_key].resource_group_name
  parent_id           = azurerm_user_assigned_identity.this[each.value.identity_key].id
  audience            = each.value.audience
  issuer              = each.value.issuer
  subject             = each.value.subject
}

resource "azurerm_role_assignment" "this" {
  for_each = local.role_assignments

  scope                                  = each.value.scope
  role_definition_name                   = each.value.role_definition_name
  role_definition_id                     = each.value.role_definition_id
  principal_id                           = azurerm_user_assigned_identity.this[each.value.identity_key].principal_id
  principal_type                         = each.value.principal_type
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
}
