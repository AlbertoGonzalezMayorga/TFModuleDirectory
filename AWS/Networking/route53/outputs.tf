output "zone_ids" {
  description = "Mapa de zone IDs por zone_key."
  value       = local.zone_ids
}

output "zone_name_servers" {
  description = "Mapa de name servers por zone_key (solo si se han creado o localizado por nombre)."
  value       = local.zone_name_servers
}

output "record_fqdns" {
  description = "FQDNs de los records creados."
  value       = [for r in aws_route53_record.this : r.fqdn]
}
