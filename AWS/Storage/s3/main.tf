resource "aws_s3_bucket" "this" {
  for_each = var.buckets

  bucket        = each.key
  force_destroy = each.value.force_destroy
  tags          = merge(var.tags, each.value.tags)
}

resource "aws_s3_bucket_public_access_block" "this" {
  for_each = var.buckets

  bucket                  = aws_s3_bucket.this[each.key].id
  block_public_acls       = each.value.public_access_block.block_public_acls
  block_public_policy     = each.value.public_access_block.block_public_policy
  ignore_public_acls      = each.value.public_access_block.ignore_public_acls
  restrict_public_buckets = each.value.public_access_block.restrict_public_buckets
}

resource "aws_s3_bucket_versioning" "this" {
  for_each = local.buckets_with_versioning

  bucket = aws_s3_bucket.this[each.key].id

  versioning_configuration {
    status = each.value.versioning_status
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  for_each = local.buckets_with_encryption

  bucket = aws_s3_bucket.this[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = each.value.server_side_encryption.kms_master_key_id
      sse_algorithm     = each.value.server_side_encryption.sse_algorithm
    }
    bucket_key_enabled = each.value.server_side_encryption.bucket_key_enabled
  }
}

resource "aws_s3_bucket_logging" "this" {
  for_each = local.buckets_with_logging

  bucket        = aws_s3_bucket.this[each.key].id
  target_bucket = each.value.logging.target_bucket
  target_prefix = each.value.logging.target_prefix
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  for_each = local.buckets_with_lifecycle

  bucket = aws_s3_bucket.this[each.key].id

  dynamic "rule" {
    for_each = each.value.lifecycle_rules

    content {
      id     = rule.value.id
      status = rule.value.status

      filter {
        prefix = rule.value.prefix
      }

      dynamic "transition" {
        for_each = rule.value.transition == null ? [] : [rule.value.transition]

        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      dynamic "expiration" {
        for_each = rule.value.expiration_days == null ? [] : [rule.value.expiration_days]

        content {
          days = expiration.value
        }
      }

      dynamic "abort_incomplete_multipart_upload" {
        for_each = rule.value.abort_incomplete_multipart_upload_days == null ? [] : [rule.value.abort_incomplete_multipart_upload_days]

        content {
          days_after_initiation = abort_incomplete_multipart_upload.value
        }
      }
    }
  }
}
