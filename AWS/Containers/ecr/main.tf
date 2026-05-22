resource "aws_ecr_repository" "this" {
  for_each = local.created_repositories

  name                 = each.key
  force_delete         = each.value.force_delete
  image_tag_mutability = each.value.image_tag_mutability

  encryption_configuration {
    encryption_type = each.value.encryption_type
    kms_key         = each.value.encryption_type == "KMS" ? each.value.encryption_kms_key : null
  }

  image_scanning_configuration {
    scan_on_push = each.value.scan_on_push
  }

  dynamic "image_tag_mutability_exclusion_filter" {
    for_each = each.value.tag_mutability_filters

    content {
      filter      = image_tag_mutability_exclusion_filter.value.filter
      filter_type = image_tag_mutability_exclusion_filter.value.filter_type
    }
  }

  tags = each.value.tags
}

resource "aws_ecr_lifecycle_policy" "this" {
  for_each = local.repositories_with_lifecycle_policy

  repository = aws_ecr_repository.this[each.key].name
  policy     = each.value.lifecycle_policy
}

resource "aws_ecr_repository_policy" "this" {
  for_each = local.repositories_with_repository_policy

  repository = aws_ecr_repository.this[each.key].name
  policy     = each.value.repository_policy
}
