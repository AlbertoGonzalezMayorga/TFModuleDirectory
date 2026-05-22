output "clusters" {
  description = "AKS clusters keyed by name."
  value = {
    for name, cluster in azurerm_kubernetes_cluster.this : name => {
      id                  = cluster.id
      name                = cluster.name
      kubelet_identity    = cluster.kubelet_identity
      node_resource_group = cluster.node_resource_group
    }
  }
}
