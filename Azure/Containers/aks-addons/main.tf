resource "azurerm_kubernetes_cluster_extension" "this" {
  for_each = local.extensions

  name                             = each.key
  cluster_id                       = var.cluster_id
  extension_type                   = each.value.extension_type
  release_train                    = each.value.release_train
  version                          = each.value.version
  target_namespace                 = each.value.target_namespace
  configuration_settings           = each.value.configuration_settings
  configuration_protected_settings = each.value.configuration_protected_settings

  dynamic "plan" {
    for_each = each.value.plan == null ? [] : [each.value.plan]

    content {
      name      = plan.value.name
      product   = plan.value.product
      publisher = plan.value.publisher
      version   = plan.value.version
    }
  }
}
