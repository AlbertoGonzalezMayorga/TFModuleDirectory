############################################
# Hosted Zones (creation)
############################################

resource "aws_route53_zone" "this" {
  for_each = local.zones_to_create

  name          = each.value.name
  comment       = try(each.value.comment, null)
  force_destroy = try(each.value.force_destroy, false)

  delegation_set_id = try(each.value.delegation_set_id, null)

  dynamic "vpc" {
    for_each = try(each.value.private, false) ? try(each.value.vpcs, []) : []
    content {
      vpc_id     = vpc.value.vpc_id
      vpc_region = try(vpc.value.vpc_region, null)
    }
  }

  tags = merge(var.tags, try(each.value.tags, {}))
}

############################################
# Hosted Zones (lookup by name)
############################################

data "aws_route53_zone" "existing" {
  for_each = local.zones_to_lookup

  name         = each.value.name
  private_zone = try(each.value.private, false)

  # If it is a private zone, if there are declared VPCs, filter by the first one to avoid ambiguity
  vpc_id = (
    try(each.value.private, false) && length(try(each.value.vpcs, [])) > 0
  ) ? each.value.vpcs[0].vpc_id : null
}

############################################
# Records
############################################

resource "aws_route53_record" "this" {
  for_each = local.records_map

  zone_id = coalesce(
    try(each.value.zone_id, null),
    local.zone_ids[each.value.zone_key]
  )

  # Allows using "@" for apex when using zone_key
  name = (
    each.value.name == "@"
    ? (try(each.value.zone_key, null) != null ? var.zones[each.value.zone_key].name : each.value.name)
    : each.value.name
  )

  type            = each.value.type
  allow_overwrite = try(each.value.allow_overwrite, false)

  set_identifier  = try(each.value.set_identifier, null)
  health_check_id = try(each.value.health_check_id, null)

  # Classic records (not aliases)
  ttl     = try(each.value.alias, null) == null ? coalesce(try(each.value.ttl, null), 300) : 300
  records = try(each.value.alias, null) == null ? try(each.value.records, null) : []

  # Alias (A/AAAA)
  dynamic "alias" {
    for_each = try(each.value.alias, null) != null ? [each.value.alias] : []
    content {
      name                   = alias.value.name
      zone_id                = alias.value.zone_id
      evaluate_target_health = try(alias.value.evaluate_target_health, false)
    }
  }

  # Routing policies (optional)
  dynamic "weighted_routing_policy" {
    for_each = try(each.value.routing_policy.weighted, null) != null ? [each.value.routing_policy.weighted] : []
    content {
      weight = weighted_routing_policy.value.weight
    }
  }

  dynamic "latency_routing_policy" {
    for_each = try(each.value.routing_policy.latency, null) != null ? [each.value.routing_policy.latency] : []
    content {
      region = latency_routing_policy.value.region
    }
  }

  dynamic "failover_routing_policy" {
    for_each = try(each.value.routing_policy.failover, null) != null ? [each.value.routing_policy.failover] : []
    content {
      type = failover_routing_policy.value.type
    }
  }

  dynamic "geolocation_routing_policy" {
    for_each = try(each.value.routing_policy.geolocation, null) != null ? [each.value.routing_policy.geolocation] : []
    content {
      continent   = try(geolocation_routing_policy.value.continent, null)
      country     = try(geolocation_routing_policy.value.country, null)
      subdivision = try(geolocation_routing_policy.value.subdivision, null)
    }
  }

  multivalue_answer_routing_policy = try(each.value.routing_policy.multivalue_answer, null) == true ? true : null

}

############################################
# NS Delegations (optional)
############################################

resource "aws_route53_record" "delegation_ns" {
  for_each = local.delegations_map

  zone_id         = each.value.parent_zone_id
  allow_overwrite = try(each.value.allow_overwrite, false)

  name = coalesce(
    try(each.value.name, null),
    var.zones[each.value.child_zone_key].name
  )

  type = "NS"
  ttl  = try(each.value.ttl, 300)

  records = coalesce(
    try(each.value.name_servers, null),
    try(local.zone_name_servers[each.value.child_zone_key], null)
  )
}