output "profiles" {
  description = "Front Door profiles keyed by name."
  value = {
    for name, profile in azurerm_cdn_frontdoor_profile.this : name => {
      id   = profile.id
      name = profile.name
    }
  }
}
