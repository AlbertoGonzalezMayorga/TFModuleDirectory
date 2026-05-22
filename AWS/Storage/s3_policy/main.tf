data "aws_iam_policy_document" "this" {
  source_policy_documents   = var.source_policy_documents
  override_policy_documents = var.override_policy_documents

  dynamic "statement" {
    for_each = var.statements

    content {
      sid       = statement.value.sid
      effect    = statement.value.effect
      actions   = statement.value.actions
      resources = statement.value.resources

      dynamic "principals" {
        for_each = statement.value.principals

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = statement.value.conditions

        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = var.bucket
  policy = data.aws_iam_policy_document.this.json
}
