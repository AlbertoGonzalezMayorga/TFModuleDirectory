locals {
  zones_to_create = {
    for k, z in var.zones : k => z
    if try(z.create, true) == true
  }

  zones_to_lookup = {
    for k, z in var.zones : k => z
    if try(z.create, true) == false && try(z.zone_id, null) == null
  }

  zones_existing_by_id = {
    for k, z in var.zones : k => z
    if try(z.create, true) == false && try(z.zone_id, null) != null
  }
}

locals {
  zone_ids = merge(
    { for k, z in aws_route53_zone.this : k => z.zone_id },
    { for k, z in local.zones_existing_by_id : k => z.zone_id },
    { for k, z in data.aws_route53_zone.existing : k => z.zone_id }
  )

  zone_name_servers = merge(
    { for k, z in aws_route53_zone.this : k => z.name_servers },
    { for k, z in data.aws_route53_zone.existing : k => z.name_servers }
  )
}

locals {
  records_map = {
    for r in var.records :
    format(
      "%s-%s-%s-%s",
      coalesce(try(r.zone_key, null), try(r.zone_id, "")),
      r.name,
      r.type,
      coalesce(try(r.set_identifier, ""), "default")
    ) => r
  }
}

locals {
  delegations_map = {
    for d in var.delegations :
    format("%s-%s-%s", d.parent_zone_id, d.child_zone_key, coalesce(try(d.name, null), "")) => d
  }
}
