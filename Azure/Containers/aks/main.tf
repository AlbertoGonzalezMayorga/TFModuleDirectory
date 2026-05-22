resource "azurerm_kubernetes_cluster" "this" {
  for_each = var.clusters

  name                              = each.key
  resource_group_name               = each.value.resource_group_name
  location                          = each.value.location
  dns_prefix                        = each.value.dns_prefix
  kubernetes_version                = each.value.kubernetes_version
  private_cluster_enabled           = each.value.private_cluster_enabled
  role_based_access_control_enabled = each.value.role_based_access_control_enabled
  sku_tier                          = each.value.sku_tier
  tags                              = merge(var.tags, each.value.tags)

  default_node_pool {
    name                 = each.value.default_node_pool.name
    vm_size              = each.value.default_node_pool.vm_size
    node_count           = each.value.default_node_pool.node_count
    auto_scaling_enabled = each.value.default_node_pool.auto_scaling_enabled
    min_count            = each.value.default_node_pool.min_count
    max_count            = each.value.default_node_pool.max_count
    vnet_subnet_id       = each.value.default_node_pool.vnet_subnet_id
    zones                = each.value.default_node_pool.zones
  }

  identity {
    type = each.value.identity_type
  }

  network_profile {
    network_plugin    = each.value.network_profile.network_plugin
    network_policy    = each.value.network_profile.network_policy
    load_balancer_sku = each.value.network_profile.load_balancer_sku
    service_cidr      = each.value.network_profile.service_cidr
    dns_service_ip    = each.value.network_profile.dns_service_ip
    outbound_type     = each.value.network_profile.outbound_type
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "this" {
  for_each = local.node_pools

  name                  = each.value.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this[each.value.cluster_key].id
  vm_size               = each.value.vm_size
  node_count            = each.value.node_count
  auto_scaling_enabled  = each.value.auto_scaling_enabled
  min_count             = each.value.min_count
  max_count             = each.value.max_count
  mode                  = each.value.mode
  vnet_subnet_id        = each.value.vnet_subnet_id
  zones                 = each.value.zones
  node_labels           = each.value.node_labels
  tags                  = merge(var.tags, each.value.tags)
}
