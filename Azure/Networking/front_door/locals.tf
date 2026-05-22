locals {
  endpoints = length(var.profiles) == 0 ? {} : merge([
    for profile_name, profile in var.profiles : {
      for endpoint_name, endpoint in profile.endpoints :
      "${profile_name}-${endpoint_name}" => merge(endpoint, {
        name        = endpoint_name
        profile_key = profile_name
      })
    }
  ]...)

  origin_groups = length(var.profiles) == 0 ? {} : merge([
    for profile_name, profile in var.profiles : {
      for group_name, group in profile.origin_groups :
      "${profile_name}-${group_name}" => merge(group, {
        name        = group_name
        profile_key = profile_name
      })
    }
  ]...)

  origins = length(var.profiles) == 0 ? {} : merge(flatten([
    for profile_name, profile in var.profiles : [
      for group_name, group in profile.origin_groups : {
        for origin_name, origin in group.origins :
        "${profile_name}-${group_name}-${origin_name}" => merge(origin, {
          name             = origin_name
          origin_group_key = "${profile_name}-${group_name}"
        })
      }
    ]
  ])...)

  routes = length(var.profiles) == 0 ? {} : merge([
    for profile_name, profile in var.profiles : {
      for route_name, route in profile.routes :
      "${profile_name}-${route_name}" => merge(route, {
        name             = route_name
        endpoint_key     = "${profile_name}-${route.endpoint_key}"
        origin_group_key = "${profile_name}-${route.origin_group_key}"
        origin_keys      = [for origin_key in route.origin_keys : "${profile_name}-${route.origin_group_key}-${origin_key}"]
      })
    }
  ]...)
}
