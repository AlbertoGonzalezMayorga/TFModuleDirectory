# Azure Helm Charts

Modulo reutilizable para instalar charts de Helm y manifiestos Kubernetes adicionales sobre un cluster, normalmente AKS. El proveedor `helm` y el proveedor `kubernetes` deben configurarse desde el root module con las credenciales del cluster de destino.

## Uso

```hcl
module "helm_charts" {
  source = "./Azure/Helm/helm-charts"

  releases = {
    external_dns = {
      name       = "external-dns"
      repository = "https://kubernetes-sigs.github.io/external-dns/"
      chart      = "external-dns"
      namespace  = "external-dns"

      values = {
        provider = "azure"
      }
    }
  }
}
```

## Entradas principales

- `releases`: mapa de releases Helm a instalar.
- `extra_manifests`: manifiestos Kubernetes que se aplican despues de los releases.

## Salidas

- `releases`: estado basico de cada release instalado.
- `extra_manifests`: objetos devueltos por los manifiestos adicionales.
