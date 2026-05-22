locals {
  node_pools = length(var.clusters) == 0 ? {} : merge([
    for cluster_name, cluster in var.clusters : {
      for pool_name, pool in cluster.node_pools :
      "${cluster_name}-${pool_name}" => merge(pool, {
        name        = pool_name
        cluster_key = cluster_name
      })
    }
  ]...)
}
