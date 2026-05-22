resource "azurerm_public_ip" "this" {
  for_each = { for name, gateway in var.application_gateways : name => gateway if gateway.create_public_ip }

  name                = "${each.key}-pip"
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = each.value.zones
  tags                = merge(var.tags, each.value.tags)
}

resource "azurerm_application_gateway" "this" {
  for_each = var.application_gateways

  name                = each.key
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  tags                = merge(var.tags, each.value.tags)

  sku {
    name     = each.value.sku_name
    tier     = each.value.sku_tier
    capacity = each.value.capacity
  }

  gateway_ip_configuration {
    name      = "gateway-ip-configuration"
    subnet_id = each.value.subnet_id
  }

  frontend_port {
    name = "http"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontend"
    public_ip_address_id = each.value.create_public_ip ? azurerm_public_ip.this[each.key].id : each.value.public_ip_address_id
  }

  backend_address_pool {
    name  = "default"
    fqdns = each.value.backend_fqdns
  }

  backend_http_settings {
    name                  = "default"
    cookie_based_affinity = "Disabled"
    port                  = each.value.backend_port
    protocol              = each.value.backend_protocol
    request_timeout       = each.value.request_timeout
  }

  http_listener {
    name                           = "http"
    frontend_ip_configuration_name = "frontend"
    frontend_port_name             = "http"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "default"
    priority                   = 100
    rule_type                  = "Basic"
    http_listener_name         = "http"
    backend_address_pool_name  = "default"
    backend_http_settings_name = "default"
  }
}
