locals {
  identities = {
    for key, identity in var.identities : key => merge(identity, {
      name                  = coalesce(identity.name, key)
      tags                  = merge(var.tags, coalesce(identity.tags, {}))
      federated_credentials = coalesce(identity.federated_credentials, {})
      role_assignments      = coalesce(identity.role_assignments, {})
    })
  }

  federated_credentials = length(local.identities) == 0 ? {} : merge([
    for identity_key, identity in local.identities : {
      for credential_key, credential in identity.federated_credentials :
      "${identity_key}-${credential_key}" => merge(credential, {
        identity_key = identity_key
        name         = coalesce(credential.name, credential_key)
      })
    }
  ]...)

  role_assignments = length(local.identities) == 0 ? {} : merge([
    for identity_key, identity in local.identities : {
      for assignment_key, assignment in identity.role_assignments :
      "${identity_key}-${assignment_key}" => merge(assignment, {
        identity_key = identity_key
      })
    }
  ]...)
}
