output "secret_arns" {
  description = "Secrets Manager secret ARNs keyed by secret name."
  value = {
    for key, secret in aws_secretsmanager_secret.this : key => secret.arn
  }
}

output "secret_names" {
  description = "Secrets Manager secret names keyed by secret name."
  value = {
    for key, secret in aws_secretsmanager_secret.this : key => secret.name
  }
}
