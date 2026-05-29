output "extensions" {
  description = "AKS cluster extensions keyed by name."
  value = {
    for key, extension in azurerm_kubernetes_cluster_extension.this : key => {
      id             = extension.id
      name           = extension.name
      extension_type = extension.extension_type
      version        = extension.version
    }
  }
}
