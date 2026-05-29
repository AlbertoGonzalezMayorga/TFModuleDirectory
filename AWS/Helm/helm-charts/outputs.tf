output "releases" {
  description = "Installed Helm releases keyed by logical name."
  value = {
    for key, release in helm_release.this : key => {
      id        = release.id
      name      = release.name
      namespace = release.namespace
      version   = release.version
      status    = release.status
    }
  }
}

output "extra_manifests" {
  description = "Extra Kubernetes manifests keyed by logical name."
  value = {
    for key, manifest in kubernetes_manifest.extra : key => manifest.object
  }
}
