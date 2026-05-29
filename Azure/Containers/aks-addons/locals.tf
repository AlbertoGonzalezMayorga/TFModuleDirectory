locals {
  extensions = {
    for key, extension in var.extensions : key => merge(extension, {
      configuration_settings           = coalesce(extension.configuration_settings, {})
      configuration_protected_settings = coalesce(extension.configuration_protected_settings, {})
    })
  }
}
