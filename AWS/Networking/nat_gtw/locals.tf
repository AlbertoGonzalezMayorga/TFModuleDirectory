locals {
  routes = length(var.nat_gateways) == 0 ? {} : merge([
    for nat_name, nat in var.nat_gateways : {
      for route_table_id in nat.route_table_ids :
      "${nat_name}-${route_table_id}" => {
        nat_gateway_key        = nat_name
        route_table_id         = route_table_id
        destination_cidr_block = nat.destination_cidr_block
      }
    }
  ]...)
}
