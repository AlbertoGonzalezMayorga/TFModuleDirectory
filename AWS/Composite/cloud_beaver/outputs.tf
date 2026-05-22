output "instance_id" {
  value       = aws_instance.cloudbeaver.id
  description = "EC2 instance ID."
}

output "public_ip" {
  value       = try(aws_eip.cloudbeaver[0].public_ip, aws_instance.cloudbeaver.public_ip)
  description = "Public IPv4 (if assigned)."
}

output "public_dns" {
  value       = aws_instance.cloudbeaver.public_dns
  description = "Public DNS (if assigned)."
}

output "cloudbeaver_url" {
  value       = var.enable_ssm_only ? null : "http://${coalesce(try(aws_eip.cloudbeaver[0].public_dns, null), aws_instance.cloudbeaver.public_dns)}:${var.cloudbeaver_port}"
  description = "Direct URL for browser access (null if enable_ssm_only=true)."
}

output "cloudbeaver_security_group_id" {
  value       = aws_security_group.cloudbeaver.id
  description = "Security group ID for CloudBeaver."
}

output "ssm_port_forward_command_for_cloudbeaver_access" {
  value       = var.enable_ssm ? "aws ssm start-session --target ${aws_instance.cloudbeaver.id} --document-name AWS-StartPortForwardingSession --parameters 'portNumber=[${var.cloudbeaver_port}],localPortNumber=[${var.cloudbeaver_port}]' --region ${var.region}" : null
  description = "If enable_ssm=true, use this to access CloudBeaver via SSM (then open http://localhost:<port>)."
}

output "ssm_port_forward_command_for_postgres_access" {
  value       = var.enable_ssm ? "aws ssm start-session --target ${aws_instance.cloudbeaver.id} --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters 'portNumber=[${var.postgres_port}],localPortNumber=[1${var.postgres_port}]' --region ${var.region}" : null
  description = "If enable_ssm=true, use this to access PostgreSQL via SSM (then open http://localhost:<port>)."
}
