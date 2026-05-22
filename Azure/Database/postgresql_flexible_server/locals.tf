locals {
  databases = length(var.servers) == 0 ? {} : merge([
    for server_name, server in var.servers : {
      for database_name, database in server.databases :
      "${server_name}-${database_name}" => {
        name       = database_name
        server_key = server_name
        charset    = database.charset
        collation  = database.collation
      }
    }
  ]...)
}
