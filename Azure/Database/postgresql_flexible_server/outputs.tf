output "servers" {
  description = "PostgreSQL Flexible Servers keyed by name."
  value = {
    for name, server in azurerm_postgresql_flexible_server.this : name => {
      fqdn = server.fqdn
      id   = server.id
      name = server.name
    }
  }
}
