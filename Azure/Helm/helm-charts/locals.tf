locals {
  releases = {
    for key, release in var.releases : key => merge(release, {
      create_namespace = coalesce(release.create_namespace, true)
      values           = coalesce(release.values, {})
      timeout          = coalesce(release.timeout, 600)
      atomic           = coalesce(release.atomic, true)
      wait             = coalesce(release.wait, true)
    })
  }

  extra_manifests = var.extra_manifests
}
