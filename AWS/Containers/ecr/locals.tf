locals {
  created_repositories = {
    for name, repository in var.repositories : name => {
      encryption_kms_key     = try(repository.encryption_kms_key, var.encryption_kms_key)
      encryption_type        = try(repository.encryption_type, var.encryption_type)
      force_delete           = try(repository.force_delete, var.force_delete)
      image_tag_mutability   = try(repository.image_tag_mutability, var.image_tag_mutability)
      lifecycle_policy       = try(repository.lifecycle_policy, var.lifecycle_policy)
      repository_policy      = try(repository.repository_policy, null)
      scan_on_push           = try(repository.scan_on_push, var.scan_on_push)
      tag_mutability_filters = try(repository.tag_mutability_filters, var.tag_mutability_filters)
      tags                   = merge(var.tags, try(repository.tags, {}))
    }
  }

  repositories_with_lifecycle_policy = {
    for name, repository in local.created_repositories : name => repository
    if repository.lifecycle_policy != null
  }

  repositories_with_repository_policy = {
    for name, repository in local.created_repositories : name => repository
    if repository.repository_policy != null
  }
}
