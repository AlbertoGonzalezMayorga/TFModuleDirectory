locals {
  subnet_associations = length(var.nat_gateways) == 0 ? {} : merge([
    for nat_name, nat in var.nat_gateways : {
      for subnet_id in nat.subnet_ids :
      "${nat_name}-${replace(subnet_id, "/", "_")}" => {
        nat_gateway_key = nat_name
        subnet_id       = subnet_id
      }
    }
  ]...)
}
