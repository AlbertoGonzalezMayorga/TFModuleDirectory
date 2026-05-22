# AWS S3 Bucket Policy Terraform Module

Modulo generico para construir y asociar una bucket policy a un bucket S3. Acepta statements declarativos y documentos JSON existentes para componer una politica final.

## Que Crea

- `data.aws_iam_policy_document`
- `aws_s3_bucket_policy`

## Ejemplo

```hcl
module "bucket_policy" {
  source = "./modules/AWS/Storage/s3_policy"

  bucket = "platform-dev-artifacts"

  statements = [
    {
      sid       = "AllowReadFromAccount"
      actions   = ["s3:GetObject"]
      resources = ["arn:aws:s3:::platform-dev-artifacts/*"]
      principals = [
        {
          type        = "AWS"
          identifiers = ["arn:aws:iam::123456789012:root"]
        }
      ]
    }
  ]
}
```

## Combinar Documentos Existentes

```hcl
module "bucket_policy" {
  source = "./modules/AWS/Storage/s3_policy"

  bucket                  = aws_s3_bucket.this.id
  source_policy_documents = [data.aws_iam_policy_document.base.json]
  override_policy_documents = [
    data.aws_iam_policy_document.override.json
  ]
}
```

## Inputs Principales

- `bucket`: nombre o ID del bucket.
- `statements`: lista de statements IAM.
- `source_policy_documents`: documentos JSON base.
- `override_policy_documents`: documentos JSON con prioridad sobre los anteriores.

## Outputs

- `policy_json`: JSON final renderizado.
