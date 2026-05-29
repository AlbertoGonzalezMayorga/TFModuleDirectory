resource "aws_secretsmanager_secret" "this" {
  for_each = var.secrets

  name                    = each.key
  description             = coalesce(each.value.description, "Managed by Terraform.")
  kms_key_id              = each.value.kms_key_id
  recovery_window_in_days = coalesce(each.value.recovery_window_in_days, 7)
  tags                    = merge(var.tags, coalesce(each.value.tags, {}))
}

resource "aws_secretsmanager_secret_version" "this" {
  for_each = var.secrets

  secret_id     = aws_secretsmanager_secret.this[each.key].id
  secret_string = jsonencode(coalesce(each.value.secret_string, {}))
}
