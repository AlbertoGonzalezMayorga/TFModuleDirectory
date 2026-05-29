# Secrets Manager Module

Modulo Terraform generico para crear secretos en AWS Secrets Manager y almacenar su valor como JSON.

## Recursos Creados

- `aws_secretsmanager_secret`
- `aws_secretsmanager_secret_version`

## Uso

```hcl
module "secrets_manager" {
  source = "./modules/secrets-manager"

  secrets = {
    "hipartners/pro/auth" = {
      secret_string = {
        DB_USERNAME   = "usr_supplier"
        DB_PASSWORD   = "change-me"
        SIGNING_KEY   = "change-me"
        CLIENT_SECRET = "change-me"
      }
    }
  }

  tags = local.tags
}
```

El `secret_string` se guarda como JSON. External Secrets puede leer cada propiedad con `remoteRef.property`.

## Inputs

| Nombre | Tipo | Default | Descripcion |
| --- | --- | --- | --- |
| `secrets` | `map(object)` | `{}` | Secretos a crear, indexados por nombre de secreto. |
| `tags` | `map(string)` | `{}` | Tags comunes. |

Cada secreto acepta:

| Campo | Tipo | Default | Descripcion |
| --- | --- | --- | --- |
| `description` | `string` | `"Managed by Terraform."` | Descripcion del secreto. |
| `secret_string` | `map(string)` | `{}` | Valores key/value que se guardan como JSON. |
| `kms_key_id` | `string` | `null` | KMS key para cifrado, si no se quiere usar la key gestionada por AWS. |
| `recovery_window_in_days` | `number` | `7` | Dias de ventana de recuperacion al borrar el secreto. |
| `tags` | `map(string)` | `{}` | Tags especificos del secreto. |

## Outputs

| Nombre | Descripcion |
| --- | --- |
| `secret_arns` | ARNs de los secretos creados. |
| `secret_names` | Nombres de los secretos creados. |

## Nota De Seguridad

Los valores de `secret_string` quedan guardados en el state de Terraform. Usa un backend remoto cifrado y con permisos restringidos. No subas ficheros `.tfvars` con secretos a Git.
