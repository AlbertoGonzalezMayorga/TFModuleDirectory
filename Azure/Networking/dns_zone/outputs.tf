output "public_zones" {
  description = "Public DNS zones."
  value = {
    for key, zone in azurerm_dns_zone.public : key => {
      id           = zone.id
      name         = zone.name
      name_servers = zone.name_servers
    }
  }
}

output "private_zones" {
  description = "Private DNS zones."
  value = {
    for key, zone in azurerm_private_dns_zone.private : key => {
      id   = zone.id
      name = zone.name
    }
  }
}
