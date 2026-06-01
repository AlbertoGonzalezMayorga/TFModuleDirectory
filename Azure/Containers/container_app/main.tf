data "azurerm_container_app_environment" "existing_environment" {
  count = var.create_container_app_environment ? 0 : 1

  name                = var.container_app_environment_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_container_app_environment" "this" {
  count               = var.create_container_app_environment ? 1 : 0
  name                = var.container_app_environment_name
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = var.tags
}

resource "azurerm_container_app" "this" {
  name                         = var.container_app_name
  resource_group_name          = var.resource_group_name
  container_app_environment_id = var.create_container_app_environment ? azurerm_container_app_environment.this[0].id : data.azurerm_container_app_environment.existing_environment[0].id
  revision_mode                = var.revision_mode
  workload_profile_name        = var.workload_profile_name

  dynamic "identity" {
    for_each = var.identity == null ? [] : [var.identity]

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "secret" {
    for_each = var.secrets

    content {
      name                = secret.key
      value               = secret.value.value
      key_vault_secret_id = secret.value.key_vault_secret_id
      identity            = secret.value.identity
    }
  }

  dynamic "registry" {
    for_each = var.registries

    content {
      server               = registry.value.server
      username             = registry.value.username
      password_secret_name = registry.value.password_secret_name
      identity             = registry.value.identity
    }
  }

  dynamic "ingress" {
    for_each = var.ingress == null ? [] : [var.ingress]

    content {
      external_enabled           = ingress.value.external_enabled
      target_port                = ingress.value.target_port
      transport                  = ingress.value.transport
      allow_insecure_connections = ingress.value.allow_insecure_connections
      exposed_port               = ingress.value.exposed_port

      dynamic "traffic_weight" {
        for_each = length(ingress.value.traffic_weight) == 0 ? [{
          percentage      = 100
          latest_revision = true
          revision_suffix = null
          label           = null
        }] : ingress.value.traffic_weight

        content {
          percentage      = traffic_weight.value.percentage
          latest_revision = traffic_weight.value.latest_revision
          revision_suffix = traffic_weight.value.revision_suffix
          label           = traffic_weight.value.label
        }
      }
    }
  }

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    container {
      name    = var.container_name
      image   = var.image
      cpu     = var.cpu
      memory  = var.memory
      command = var.command
      args    = var.args

      dynamic "env" {
        for_each = var.env

        content {
          name        = env.key
          value       = env.value.value
          secret_name = env.value.secret_name
        }
      }
    }
  }

  tags = var.tags
}

resource "azurerm_container_app_custom_domain" "this" {
  for_each = var.custom_domains

  name                                     = each.value.name
  container_app_id                         = azurerm_container_app.this.id
  certificate_binding_type                 = each.value.certificate_binding_type
  container_app_environment_certificate_id = each.value.container_app_environment_certificate_id

  lifecycle {
    ignore_changes = [
      certificate_binding_type,
      container_app_environment_certificate_id,
    ]
  }
}
