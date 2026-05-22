resource "azurerm_cdn_frontdoor_profile" "this" {
  for_each = var.profiles

  name                = each.key
  resource_group_name = each.value.resource_group_name
  sku_name            = each.value.sku_name
  tags                = merge(var.tags, each.value.tags)
}

resource "azurerm_cdn_frontdoor_endpoint" "this" {
  for_each = local.endpoints

  name                     = each.value.name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this[each.value.profile_key].id
  enabled                  = each.value.enabled
  tags                     = merge(var.tags, each.value.tags)
}

resource "azurerm_cdn_frontdoor_origin_group" "this" {
  for_each = local.origin_groups

  name                     = each.value.name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this[each.value.profile_key].id
  session_affinity_enabled = each.value.session_affinity_enabled

  load_balancing {
    sample_size                 = 4
    successful_samples_required = 3
  }
}

resource "azurerm_cdn_frontdoor_origin" "this" {
  for_each = local.origins

  name                           = each.value.name
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.this[each.value.origin_group_key].id
  host_name                      = each.value.host_name
  http_port                      = each.value.http_port
  https_port                     = each.value.https_port
  origin_host_header             = each.value.origin_host_header
  certificate_name_check_enabled = each.value.certificate_name_check_enabled
  priority                       = each.value.priority
  weight                         = each.value.weight
  enabled                        = each.value.enabled
}

resource "azurerm_cdn_frontdoor_route" "this" {
  for_each = local.routes

  name                          = each.value.name
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.this[each.value.endpoint_key].id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.this[each.value.origin_group_key].id
  cdn_frontdoor_origin_ids      = [for origin_key in each.value.origin_keys : azurerm_cdn_frontdoor_origin.this[origin_key].id]
  enabled                       = each.value.enabled
  forwarding_protocol           = each.value.forwarding_protocol
  https_redirect_enabled        = each.value.https_redirect_enabled
  patterns_to_match             = each.value.patterns_to_match
  supported_protocols           = each.value.supported_protocols
}
