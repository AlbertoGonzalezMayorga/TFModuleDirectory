resource "aws_iam_role" "this" {
  for_each = local.roles

  name                  = each.value.name
  name_prefix           = each.value.name == null ? each.value.name_prefix : null
  path                  = each.value.path
  description           = each.value.description
  permissions_boundary  = each.value.permissions_boundary
  max_session_duration  = each.value.max_session_duration
  force_detach_policies = each.value.force_detach_policies
  assume_role_policy    = each.value.assume_role_policy

  tags = each.value.tags
}

resource "aws_iam_role_policy" "this" {
  for_each = local.inline_policies

  name   = each.value.name
  role   = aws_iam_role.this[each.value.role_key].id
  policy = each.value.policy
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = local.managed_policy_attachments

  role       = aws_iam_role.this[each.value.role_key].name
  policy_arn = each.value.policy_arn
}
