output "roles" {
  description = "IAM roles keyed by logical name."
  value = {
    for key, role in aws_iam_role.this : key => {
      arn  = role.arn
      id   = role.id
      name = role.name
      path = role.path
    }
  }
}

output "role_arns" {
  description = "IAM role ARNs keyed by logical name."
  value = {
    for key, role in aws_iam_role.this : key => role.arn
  }
}

output "role_names" {
  description = "IAM role names keyed by logical name."
  value = {
    for key, role in aws_iam_role.this : key => role.name
  }
}
