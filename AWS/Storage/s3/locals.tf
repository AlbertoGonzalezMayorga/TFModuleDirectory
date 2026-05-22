locals {
  buckets_with_versioning = {
    for name, bucket in var.buckets : name => bucket
    if bucket.versioning_status != null
  }

  buckets_with_encryption = {
    for name, bucket in var.buckets : name => bucket
    if bucket.server_side_encryption != null
  }

  buckets_with_lifecycle = {
    for name, bucket in var.buckets : name => bucket
    if length(bucket.lifecycle_rules) > 0
  }

  buckets_with_logging = {
    for name, bucket in var.buckets : name => bucket
    if bucket.logging != null
  }
}
