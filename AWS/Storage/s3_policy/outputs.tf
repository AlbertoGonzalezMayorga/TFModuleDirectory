output "policy_json" {
  description = "Rendered bucket policy JSON."
  value       = data.aws_iam_policy_document.this.json
}
