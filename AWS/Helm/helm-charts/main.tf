resource "helm_release" "this" {
  for_each = local.releases

  name             = each.value.name
  repository       = each.value.repository
  chart            = each.value.chart
  version          = each.value.chart_version
  namespace        = each.value.namespace
  create_namespace = each.value.create_namespace
  timeout          = each.value.timeout
  atomic           = each.value.atomic
  wait             = each.value.wait

  values = [
    yamlencode(each.value.values)
  ]
}

resource "kubernetes_manifest" "extra" {
  for_each = local.extra_manifests

  manifest = each.value

  depends_on = [
    helm_release.this,
  ]
}
